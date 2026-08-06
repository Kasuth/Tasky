
resource "kubernetes_deployment" "tasky" {
  spec {
    template {
      spec {
        container {
          name  = "tasky"
          image = var.app_image  # Dynamically receives image from CI/CD
          
          # Force K8s to pull fresh builds
          image_pull_policy = "Always"

          port { container_port = 8080 }

          env {
            name  = "MONGODB_URI"
            value = "mongodb://taskyUser:Tasky123@${var.mongo_ip}:27017/go-mongodb?authSource=admin"
          }
        }
      }
    }
  }
}
