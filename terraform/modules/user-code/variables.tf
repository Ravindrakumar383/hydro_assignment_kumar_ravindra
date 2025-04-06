variable "namespace" {
  type        = string
  description = "Kubernetes namespace for the user code deployment"
}

variable "ecr_repository_url" {
  type        = string
  description = "URL of the ECR repository"
}

variable "image_tag" {
  type        = string
  description = "Tag for the Docker image"
  default     = "latest"
}

variable "service_account_name" {
  type        = string
  description = "Name of the Kubernetes Service Account to use"
}

variable "pipeline_configs" {
  type = map(object({
    name      = string
    port      = number
    replicas  = number
    cpu_request  = string
    memory_request = string
    cpu_limit    = string
    memory_limit = string
  }))
  description = "Map of pipeline names to their configurations"
}