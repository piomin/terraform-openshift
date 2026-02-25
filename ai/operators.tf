resource "kubernetes_manifest" "nfd-group" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata"   = {
      "name"      = "openshift-nfd"
      "namespace" = "openshift-nfd"
    }
    "spec" = {
      "upgradeStrategy" = "Default"
      "targetNamespaces" = ["openshift-nfd"]
    }
  }
}

resource "kubernetes_manifest" "nfd-operator" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "nfd"
      "namespace" = "openshift-nfd"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "nfd"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
      "startingCSV"         = "nfd.4.18.0-202505200035"
    }
  }
}

resource "time_sleep" "wait-150-seconds-1" {
  depends_on = [kubernetes_manifest.nfd-operator]

  create_duration = "150s"
}

resource "kubectl_manifest" "nfd-instance" {
  depends_on = [time_sleep.wait-150-seconds-1]
  yaml_body = <<YAML
apiVersion: nfd.openshift.io/v1
kind: NodeFeatureDiscovery
metadata:
  name: nfd-instance
  namespace: openshift-nfd
spec:
  workerConfig:
    configData:
      core:
        sleepInterval: 60s
      sources:
        pci:
          deviceClassWhitelist:
            - "0200"
            - "03"
            - "12"
          deviceLabelFields:
            - "vendor"
  operand:
    imagePullPolicy: IfNotPresent
    servicePort: 12000
  customConfig:
    configData: {}
YAML
}

# resource "kubernetes_manifest" "nfd-instance" {
#   depends_on = [time_sleep.wait-150-seconds-1]
#   manifest = {
#     "apiVersion" = "nfd.openshift.io/v1"
#     "kind"       = "NodeFeatureDiscovery"
#     "metadata"   = {
#       "name"      = "nfd-instance"
#       "namespace" = "openshift-nfd"
#     }
#     "spec" = {
#       "workerConfig" = {
#         "configData" = <<-EOT
#           core:
#             sleepInterval: 60s
#           sources:
#             pci:
#               deviceClassWhitelist:
#                 - "0200"
#                 - "03"
#                 - "12"
#               deviceLabelFields:
#                 - "vendor"
#         EOT
#       }
#       "operand" = {
#         "imagePullPolicy" = "IfNotPresent"
#         "servicePort"     = 12000
#       }
#       "customConfig" = {
#         "configData" = ""
#       }
#     }
#   }
# }

resource "kubernetes_manifest" "nvidia-gpu-group" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata"   = {
      "name"      = "nvidia-gpu-operator"
      "namespace" = "nvidia-gpu-operator"
    }
    "spec" = {
      "upgradeStrategy" = "Default"
      "targetNamespaces" = ["nvidia-gpu-operator"]
    }
  }
}

resource "kubernetes_manifest" "nvidia-gpu-operator" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "gpu-operator-certified"
      "namespace" = "nvidia-gpu-operator"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "gpu-operator-certified"
      "source"              = "certified-operators"
      "sourceNamespace"     = "openshift-marketplace"
      "startingCSV"         = "gpu-operator-certified.v25.3.1"
    }
  }
}

resource "time_sleep" "wait-150-seconds-2" {
  depends_on = [kubernetes_manifest.nvidia-gpu-operator]

  create_duration = "150s"
}

resource "kubectl_manifest" "nvidia-gpu-cluster-policy" {
  depends_on = [time_sleep.wait-150-seconds-1]
  yaml_body = <<YAML
apiVersion: nvidia.com/v1
kind: ClusterPolicy
metadata:
  name: gpu-cluster-policy
spec:
  migManager:
    enabled: true
    config:
      default: all-disabled
      name: default-mig-parted-config
  operator:
    defaultRuntime: crio
    initContainer: {}
    runtimeClass: nvidia
    use_ocp_driver_toolkit: true
  dcgm:
    enabled: true
  gfd:
    enabled: true
  dcgmExporter:
    enabled: true
    config:
      name: ""
    serviceMonitor:
      enabled: true
  cdi:
    enabled: false
    default: false
  driver:
    enabled: true
    licensingConfig:
      nlsEnabled: true
      configMapName: ""
    kernelModuleType: auto
    certConfig:
      name: ""
    kernelModuleConfig:
      name: ""
    upgradePolicy:
      autoUpgrade: true
      drain:
        deleteEmptyDir: false
        enable: false
        force: false
        timeoutSeconds: 300
      maxParallelUpgrades: 1
      maxUnavailable: "25%"
      podDeletion:
        deleteEmptyDir: false
        force: false
        timeoutSeconds: 300
      waitForCompletion:
        timeoutSeconds: 0
    repoConfig:
      configMapName: ""
    virtualTopology:
      config: ""
    useNvidiaDriverCRD: false
  devicePlugin:
    enabled: true
    config:
      name: ""
      default: ""
    mps:
      root: /run/nvidia/mps
  gdrcopy:
    enabled: false
  kataManager:
    config:
      artifactsDir: /opt/nvidia-gpu-operator/artifacts/runtimeclasses
  mig:
    strategy: single
  sandboxDevicePlugin:
    enabled: true
  validator:
    plugin:
      env:
        - name: WITH_WORKLOAD
          value: "false"
  nodeStatusExporter:
    enabled: true
  daemonsets:
    rollingUpdate:
      maxUnavailable: "1"
    updateStrategy: RollingUpdate
  sandboxWorkloads:
    defaultWorkload: container
    enabled: false
  gds:
    enabled: false
  vgpuManager:
    enabled: false
  vfioManager:
    enabled: true
  toolkit:
    enabled: true
    installDir: /usr/local/nvidia
YAML
}

# resource "kubernetes_manifest" "nvidia-gpu-cluster-policy" {
#   depends_on = [time_sleep.wait-150-seconds-2]
#   manifest = {
#     "apiVersion" = "nvidia.com/v1"
#     "kind"       = "ClusterPolicy"
#     "metadata"   = {
#       "name" = "gpu-cluster-policy"
#     }
#     "spec" = {
#       "migManager" = {
#         "enabled" = true
#         "config"  = {
#           "default" = "all-disabled"
#           "name"    = "default-mig-parted-config"
#         }
#       }
#       "operator" = {
#         "defaultRuntime"          = "crio"
#         "initContainer"           = {}
#         "runtimeClass"            = "nvidia"
#         "use_ocp_driver_toolkit"  = true
#       }
#       "dcgm" = {
#         "enabled" = true
#       }
#       "gfd" = {
#         "enabled" = true
#       }
#       "dcgmExporter" = {
#         "enabled" = true
#         "config"  = {
#           "name" = ""
#         }
#         "serviceMonitor" = {
#           "enabled" = true
#         }
#       }
#       "cdi" = {
#         "enabled" = false
#         "default" = false
#       }
#       "driver" = {
#         "enabled" = true
#         "licensingConfig" = {
#           "nlsEnabled"   = true
#           "configMapName" = ""
#         }
#         "kernelModuleType" = "auto"
#         "certConfig" = {
#           "name" = ""
#         }
#         "kernelModuleConfig" = {
#           "name" = ""
#         }
#         "upgradePolicy" = {
#           "autoUpgrade" = true
#           "drain" = {
#             "deleteEmptyDir" = false
#             "enable"         = false
#             "force"          = false
#             "timeoutSeconds" = 300
#           }
#           "maxParallelUpgrades" = 1
#           "maxUnavailable"      = "25%"
#           "podDeletion" = {
#             "deleteEmptyDir" = false
#             "force"          = false
#             "timeoutSeconds" = 300
#           }
#           "waitForCompletion" = {
#             "timeoutSeconds" = 0
#           }
#         }
#         "repoConfig" = {
#           "configMapName" = ""
#         }
#         "virtualTopology" = {
#           "config" = ""
#         }
#         "useNvidiaDriverCRD" = false
#       }
#       "devicePlugin" = {
#         "enabled" = true
#         "config"  = {
#           "name"    = ""
#           "default" = ""
#         }
#         "mps" = {
#           "root" = "/run/nvidia/mps"
#         }
#       }
#       "gdrcopy" = {
#         "enabled" = false
#       }
#       "kataManager" = {
#         "config" = {
#           "artifactsDir" = "/opt/nvidia-gpu-operator/artifacts/runtimeclasses"
#         }
#       }
#       "mig" = {
#         "strategy" = "single"
#       }
#       "sandboxDevicePlugin" = {
#         "enabled" = true
#       }
#       "validator" = {
#         "plugin" = {
#           "env" = [
#             {
#               "name"  = "WITH_WORKLOAD"
#               "value" = "false"
#             }
#           ]
#         }
#       }
#       "nodeStatusExporter" = {
#         "enabled" = true
#       }
#       "daemonsets" = {
#         "rollingUpdate" = {
#           "maxUnavailable" = "1"
#         }
#         "updateStrategy" = "RollingUpdate"
#       }
#       "sandboxWorkloads" = {
#         "defaultWorkload" = "container"
#         "enabled"         = false
#       }
#       "gds" = {
#         "enabled" = false
#       }
#       "vgpuManager" = {
#         "enabled" = false
#       }
#       "vfioManager" = {
#         "enabled" = true
#       }
#       "toolkit" = {
#         "enabled"    = true
#         "installDir" = "/usr/local/nvidia"
#       }
#     }
#   }
# }

resource "kubernetes_manifest" "ossm" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "servicemeshoperator"
      "namespace" = "openshift-operators"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "servicemeshoperator"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_namespace_v1" "serverless-namespace" {
  metadata {
    name = "openshift-serverless"
  }
}

resource "kubernetes_manifest" "serverless-group" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata"   = {
      "name"      = "serverless-operator"
      "namespace" = "openshift-serverless"
    }
    "spec" = {
      "upgradeStrategy" = "Default"
    }
  }
}

resource "kubernetes_manifest" "serverless" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "serverless-operator"
      "namespace" = "openshift-serverless"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "serverless-operator"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_namespace" "rhai-namespace" {
  metadata {
    name = "redhat-ods-operator"
  }
}

resource "kubernetes_manifest" "rhai-group" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata"   = {
      "name"      = "rhods-operator"
      "namespace" = "redhat-ods-operator"
    }
    "spec" = {
      "upgradeStrategy" = "Default"
    }
  }
}

resource "kubernetes_manifest" "rhai" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "rhods-operator"
      "namespace" = "redhat-ods-operator"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "rhods-operator"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

resource "kubernetes_manifest" "authorino" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "authorino-operator"
      "namespace" = "openshift-operators"
    }
    "spec" = {
      "channel"             = "stable"
      "installPlanApproval" = "Automatic"
      "name"                = "authorino-operator"
      "source"              = "community-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}