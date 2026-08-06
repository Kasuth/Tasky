variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR block for this environment"
  type        = string
  default     = "10.10.0.0/20"
}

variable "app_image" {
  description = "Container image URI for Tasky"
  type        = string
  default     = "jeffthorne/tasky:latest"
}

variable "mongo_ip" {
  description = "Internal IP address of the MongoDB VM"
  type        = string
  default     = "10.0.0.2"
}
