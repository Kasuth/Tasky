resource "kubernetes_deployment" "tasky" {
  metadata {
    name = "tasky-deployment"
    labels = {
      app = "tasky"
      env = var.environment
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "tasky"
      }
    }

    template {
      metadata {
        labels = {
          app = "tasky"
          env = var.environment
        }
      }

      spec {
        container {
          name  = "tasky"
          image = var.app_image

          image_pull_policy = "Always"

          port {
            container_port = 8080
          }

          env {
            name  = "MONGODB_URI"
            value = "mongodb://taskyUser:Tasky123@${var.mongo_ip}:27017/go-mongodb?authSource=admin"
          }

          env {
            name  = "SECRET_KEY"
            value = "wiz-secret-key"
          }
        }
      }
    }
  }
}
