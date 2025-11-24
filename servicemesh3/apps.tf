resource "kubernetes_secret" "person-db-secret" {
  metadata {
    name      = "person-db"
    namespace = "mesh"
  }
  data = {
    postgres-password = "123456"
    password          = "123456"
    database-user     = "person-db"
    database-name     = "person-db"
  }
}

resource "kubernetes_secret" "insurance-db-secret" {
  metadata {
    name      = "insurance-db"
    namespace = "mesh"
  }
  data = {
    postgres-password = "123456"
    password          = "123456"
    database-user     = "insurance-db"
    database-name     = "insurance-db"
  }
}

resource "helm_release" "person-db" {
  chart            = "postgresql"
  name             = "person-db"
  namespace        = "mesh"
  repository       = "https://charts.bitnami.com/bitnami"

  values = [
    file("manifests/person-db-values.yaml")
  ]
}

resource "helm_release" "insurance-db" {
  chart            = "postgresql"
  name             = "insurance-db"
  namespace        = "mesh"
  repository       = "https://charts.bitnami.com/bitnami"

  values = [
    file("manifests/insurance-db-values.yaml")
  ]
}

resource "kubernetes_deployment" "quarkus-insurance-app" {
  metadata {
    name      = "quarkus-insurance-app"
    namespace = "mesh"
    annotations = {
      "sidecar.istio.io/inject": "true"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "quarkus-insurance-app"
        version = "v1"
      }
    }
    template {
      metadata {
        labels = {
          app = "quarkus-insurance-app"
          version = "v1"
        }
        annotations = {
          "sidecar.istio.io/inject": "true"
        }
      }
      spec {
        container {
          name = "quarkus-insurance-app"
          image = "piomin/quarkus-insurance-app:v1"
          port {
            container_port = 8080
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                key = "database-user"
                name = "insurance-db"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                key = "password"
                name = "insurance-db"
              }
            }
          }
          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                key = "database-name"
                name = "insurance-db"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "quarkus-insurance-app" {
  metadata {
    name = "quarkus-insurance-app"
    namespace = "mesh"
    labels = {
      app = "quarkus-insurance-app"
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "quarkus-insurance-app"
    }
    port {
      port = 8080
      name = "http"
    }
  }
}

resource "kubernetes_deployment" "quarkus-person-app-v1" {
  metadata {
    name      = "quarkus-person-app-v1"
    namespace = "mesh"
    annotations = {
      "sidecar.istio.io/inject": "true"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "quarkus-person-app"
        version = "v1"
      }
    }
    template {
      metadata {
        labels = {
          app = "quarkus-person-app"
          version = "v1"
        }
        annotations = {
          "sidecar.istio.io/inject": "true"
        }
      }
      spec {
        container {
          name = "quarkus-person-app"
          image = "piomin/quarkus-person-app:v1"
          port {
            container_port = 8080
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                key = "database-user"
                name = "person-db"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                key = "password"
                name = "person-db"
              }
            }
          }
          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                key = "database-name"
                name = "person-db"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "quarkus-person-app-v2" {
  metadata {
    name      = "quarkus-person-app-v2"
    namespace = "mesh"
    annotations = {
      "sidecar.istio.io/inject": "true"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "quarkus-person-app"
        version = "v2"
      }
    }
    template {
      metadata {
        labels = {
          app = "quarkus-person-app"
          version = "v2"
        }
        annotations = {
          "sidecar.istio.io/inject": "true"
        }
      }
      spec {
        container {
          name = "quarkus-person-app"
          image = "piomin/quarkus-person-app:v2"
          port {
            container_port = 8080
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                key = "database-user"
                name = "person-db"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                key = "password"
                name = "person-db"
              }
            }
          }
          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                key = "database-name"
                name = "person-db"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "quarkus-person-app" {
  metadata {
    name = "quarkus-person-app"
    namespace = "mesh"
    labels = {
      app = "quarkus-person-app"
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "quarkus-person-app"
    }
    port {
      port = 8080
      name = "http"
    }
  }
}