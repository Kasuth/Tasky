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
    type = "NodePort"
    port {
      port        = 8080
      target_port = 8080
    }
  }
}

# 1. Generate Private Key for TLS Certificate
resource "tls_private_key" "tasky_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# 2. Generate Self-Signed TLS Certificate
resource "tls_self_signed_cert" "tasky_cert" {
  private_key_pem = tls_private_key.tasky_key.private_key_pem

  subject {
    common_name   = "${var.environment}.tasky.local"
    organization = "Tasky App"
  }

  validity_period_hours = 8760 # Valid for 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# 3. Create the Kubernetes TLS Secret automatically
resource "kubernetes_secret_v1" "tasky_tls" {
  metadata {
    name      = "tasky-tls-secret"
    namespace = "default"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.tasky_cert.cert_pem
    "tls.key" = tls_private_key.tasky_key.private_key_pem
  }
}

# 4. Create the GCE Ingress automatically
resource "kubernetes_ingress_v1" "tasky_ingress" {
  metadata {
    name      = "tasky-ingress"
    namespace = "default"
  }

  spec {
    ingress_class_name = "gce"

    tls {
      secret_name = kubernetes_secret_v1.tasky_tls.metadata[0].name
    }

    rule {
      http {
        path {
          path      = "/*"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service_v1.tasky_service.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_v1.tasky_service,
    kubernetes_secret_v1.tasky_tls
  ]
}
