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
  description = "List of subnet IDs for the EKS node group"
}

variable "instance_types" {
  type        = list(string)
  description = "Instance types for the EKS node group"
}

variable "desired_size" {
  type        = number
  description = "Desired number of nodes in the EKS node group"
}

variable "min_size" {
  type        = number
  description = "Minimum number of nodes in the EKS node group"
}

variable "max_size" {
  type        = number
  description = "Maximum number of nodes in the EKS node group"
}