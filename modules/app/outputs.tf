output "app_public_ip" {
  description = "Public IP address of the Tasky application"
  value       = try(kubernetes_service_v1.tasky_service.status[0].load_balancer[0].ingress[0].ip, "Pending LoadBalancer IP...")
}
