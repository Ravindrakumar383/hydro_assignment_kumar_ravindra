variable "namespace" {
  type        = string
  description = "Kubernetes namespace for Dagster"
}

variable "rds_endpoint" {
  type        = string
  description = "Endpoint of the RDS PostgreSQL instance"
}

variable "db_password" {
  type        = string
  description = "Password for the RDS PostgreSQL database"
  sensitive   = true
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "log_group_name" {
  type        = string
  description = "Name of the CloudWatch log group for Dagster logs"
}

variable "node_group_name" {
  type        = string
  description = "Name of the EKS node group"
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the S3 bucket used for Dagster storage"
}

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