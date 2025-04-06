variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs"
}