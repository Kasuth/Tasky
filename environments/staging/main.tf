form {
  required_version = ">= 1.0"
  backend "gcs" {
    bucket = "mongodb-backups-clgcporg10-151"
    prefix = "terraform/state/dev"
  }
}

variable "project_id" { type = string }
variable "app_image" {
  type    = string
  default = "jeffthorne/tasky:latest"
}

module "dev_app" {
  source      = "../../modules/app"
  project_id  = var.project_id
  environment = "dev"
  subnet_cidr = "10.10.0.0/20"
  app_image   = var.app_image
}

output "dev_app_public_ip" {
  value = module.dev_app.app_public_ip
}
