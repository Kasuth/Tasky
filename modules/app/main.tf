variable "app_image" {
  type    = string
  default = "jeffthorne/tasky:latest"
}

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
            value = "mongodb://taskyUser:Tasky123@${google_compute_instance.mongo_vm.network_interface.0.network_ip}:27017/go-mongodb?authSource=admin"
          }
        }
      }
    }
  }
}
