terraform {
  required_version = ">= 1.0"
  backend "gcs" {
    bucket = "mongodb-backups-clgcporg10-151"
    prefix = "terraform/state/dev"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

variable "project_id" { type = string }
variable "app_image" {
  type    = string
  default = "jeffthorne/tasky:latest"
}

# 1. Fetch OAuth2 Access Token for GCP
data "google_client_config" "default" {}

# 2. Fetch GKE Cluster Information
data "google_container_cluster" "gke" {
  name     = "wiz-gke-cluster"     # e.g., "dev-cluster" or "tasky-cluster"
  location = "us-east4-a" # e.g., "us-east4" or "us-east4-a"
  project  = var.project_id
}

# 3. Authenticate Kubernetes Provider to GKE
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
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
