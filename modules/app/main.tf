resource "kubernetes_deployment_v1" "tasky" {
  metadata {
    name = "tasky-deployment-${var.environment}"
    labels = {
      app = "tasky-${var.environment}"
      env = var.environment
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "tasky-${var.environment}"
      }
    }

    template {
      metadata {
        labels = {
          app = "tasky-${var.environment}"
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
            value = "mongodb://taskyUser:Tasky123@${var.mongo_ip}:27017/tasky-${var.environment}?authSource=admin"
          }

          env {
            name  = "SECRET_KEY"
            value = "wiz-secret-key-${var.environment}"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "tasky_service" {
  metadata {
    name = "tasky-service-${var.environment}" # Dynamic name
  }
  spec {
    selector = {
      app = "tasky-${var.environment}"
    }
    type = "LoadBalancer"
    port {
      port        = 8080
      target_port = 8080
    }
  }
}
