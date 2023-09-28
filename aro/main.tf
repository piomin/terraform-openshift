data "azurerm_client_config" "current" {
}

data "azuread_client_config" "current" {}

data "azurerm_resource_group" "my_group" {
  name = "openenv-${var.guid}"
}

resource "random_string" "random" {
  length           = 10
  numeric          = false
  special          = false
  upper            = false
}

locals {
  resource_group_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/aro-${random_string.random.result}-${data.azurerm_resource_group.my_group.location}"
}

#output "subid" {
#  value = data.azurerm_client_config.current.subscription_id
#}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "aro-vnet-${var.guid}"
  address_space       = ["10.0.0.0/22"]
  location            = data.azurerm_resource_group.my_group.location
  resource_group_name = data.azurerm_resource_group.my_group.name
}

resource "azurerm_subnet" "master_subnet" {
  name                 = "master_subnet"
  resource_group_name  = data.azurerm_resource_group.my_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.0.0/23"]
  service_endpoints    = ["Microsoft.ContainerRegistry"]
  private_link_service_network_policies_enabled  = false
  depends_on = [azurerm_virtual_network.virtual_network]
}

resource "azurerm_subnet" "worker_subnet" {
  name                 = "worker_subnet"
  resource_group_name  = data.azurerm_resource_group.my_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.2.0/23"]
  service_endpoints    = ["Microsoft.ContainerRegistry"]
  depends_on = [azurerm_virtual_network.virtual_network]
}

resource "azuread_application" "aro_app" {
  display_name = "aro_app"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "aro_app" {
  application_id               = azuread_application.aro_app.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "aro_app" {
  service_principal_id = azuread_service_principal.aro_app.object_id
}

resource "azurerm_role_assignment" "aro_cluster_service_principal_uaa" {
  scope                = data.azurerm_resource_group.my_group.id
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.aro_app.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aro_cluster_service_principal_network_contributor_pre" {
  scope                = data.azurerm_resource_group.my_group.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aro_app.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aro_cluster_service_principal_network_contributor" {
  scope                = azurerm_virtual_network.virtual_network.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aro_app.id
  skip_service_principal_aad_check = true
}

data "azuread_service_principal" "aro_app" {
  display_name = "Azure Red Hat OpenShift RP"
  depends_on = [azuread_service_principal.aro_app]
}

resource "azurerm_role_assignment" "aro_resource_provider_service_principal_network_contributor" {
  scope                = azurerm_virtual_network.virtual_network.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.aro_app.id
  skip_service_principal_aad_check = true
}

resource "azapi_resource" "aro_cluster" {
  name      = "aro-cluster-${var.guid}"
  parent_id = data.azurerm_resource_group.my_group.id
  type      = "Microsoft.RedHatOpenShift/openShiftClusters@2023-07-01-preview"
  location  = data.azurerm_resource_group.my_group.location
  body = jsonencode({
    properties = {
      clusterProfile = {
        resourceGroupId      = local.resource_group_id
        pullSecret           = file("~/Downloads/pull-secret-latest.txt")
        domain               = random_string.random.result
        fipsValidatedModules = "Disabled"
        version              = "4.12.25"
      }
      networkProfile = {
        podCidr              = "10.128.0.0/14"
        serviceCidr          = "172.30.0.0/16"
      }
      servicePrincipalProfile = {
#        clientId             = data.azurerm_client_config.current.client_id
        clientId             = azuread_service_principal.aro_app.application_id
        clientSecret         = azuread_service_principal_password.aro_app.value
      }
      masterProfile = {
        vmSize               = "Standard_D8s_v3"
        subnetId             = azurerm_subnet.master_subnet.id
        encryptionAtHost     = "Disabled"
      }
      workerProfiles = [
        {
          name               = "worker"
          vmSize             = "Standard_D8s_v3"
          diskSizeGB         = 128
          subnetId           = azurerm_subnet.worker_subnet.id
          count              = 3
          encryptionAtHost   = "Disabled"
        }
      ]
      apiserverProfile = {
        visibility           = "Public"
      }
      ingressProfiles = [
        {
          name               = "default"
          visibility         = "Public"
        }
      ]
    }
  })
  depends_on = [
    azurerm_subnet.worker_subnet,
    azurerm_subnet.master_subnet,
    azuread_service_principal_password.aro_app,
    azurerm_role_assignment.aro_resource_provider_service_principal_network_contributor
  ]
}