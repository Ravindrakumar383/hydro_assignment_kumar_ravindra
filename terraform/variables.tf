
variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the EKS cluster and RDS"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for Dagster"
  default     = "dagster"
}

variable "ecr_repository_url" {
  type        = string
  description = "URL of the ECR repository"
}

# Pipeline Configurations
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
  default = {
    "geospatial-pipeline" = {
      name      = "geospatial-pipeline"
      port      = 3030
      replicas  = 1
      cpu_request  = "200m"
      memory_request = "512Mi"
      cpu_limit    = "500m"
      memory_limit = "1Gi"
    }
   
  }
}

# EKS Node Group Variables
variable "node_group_instance_types" {
  type        = list(string)
  description = "Instance types for the EKS node group"
}

variable "node_group_desired_size" {
  type        = number
  description = "Desired number of nodes in the EKS node group"
}

variable "node_group_min_size" {
  type        = number
  description = "Minimum number of nodes in the EKS node group"
}

variable "node_group_max_size" {
  type        = number
  description = "Maximum number of nodes in the EKS node group"
}

# RDS Variables
variable "rds_instance_class" {
  type        = string
  description = "Instance class for the RDS PostgreSQL database"
}

variable "rds_allocated_storage" {
  type        = number
  description = "Allocated storage for the RDS instance (in GB)"
}

variable "rds_multi_az" {
  type        = bool
  description = "Enable Multi-AZ for RDS (high availability)"
}

# CloudWatch Variables
variable "log_retention_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs"
}

# Dagster Webserver Variables
variable "webserver_replica_count" {
  type        = number
  description = "Number of replicas for the Dagster webserver"
}

variable "webserver_cpu_request" {
  type        = string
  description = "CPU request for the Dagster webserver"
}

variable "webserver_memory_request" {
  type        = string
  description = "Memory request for the Dagster webserver"
}

variable "webserver_cpu_limit" {
  type        = string
  description = "CPU limit for the Dagster webserver"
}

variable "webserver_memory_limit" {
  type        = string
  description = "Memory limit for the Dagster webserver"
}

variable "webserver_min_replicas" {
  type        = number
  description = "Minimum replicas for webserver autoscaling"
}

variable "webserver_max_replicas" {
  type        = number
  description = "Maximum replicas for webserver autoscaling"
}

variable "webserver_target_cpu_utilization" {
  type        = number
  description = "Target CPU utilization percentage for webserver autoscaling"
}

# Dagster Daemon Variables
variable "daemon_replica_count" {
  type        = number
  description = "Number of replicas for the Dagster daemon"
}

variable "daemon_cpu_request" {
  type        = string
  description = "CPU request for the Dagster daemon"
}

variable "daemon_memory_request" {
  type        = string
  description = "Memory request for the Dagster daemon"
}

variable "daemon_cpu_limit" {
  type        = string
  description = "CPU limit for the Dagster daemon"
}

variable "daemon_memory_limit" {
  type        = string
  description = "Memory limit for the Dagster daemon"
}

variable "daemon_min_replicas" {
  type        = number
  description = "Minimum replicas for daemon autoscaling"
}

variable "daemon_max_replicas" {
  type        = number
  description = "Maximum replicas for daemon autoscaling"
}

variable "daemon_target_cpu_utilization" {
  type        = number
  description = "Target CPU utilization percentage for daemon autoscaling"
}