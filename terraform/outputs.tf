output "dagster_webserver_url" {
  description = "URL to access the Dagster webserver (Dagit UI)"
  value       = module.dagster_helm.webserver_url
}

output "dagster_namespace" {
  description = "Kubernetes namespace where Dagster is deployed"
  value       = module.dagster_helm.namespace
}

output "dagster_helm_release_status" {
  description = "Status of the Dagster Helm release"
  value       = module.dagster_helm.helm_release_status
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Dagster storage"
  value       = module.s3.bucket_name
}

output "rds_endpoint" {
  description = "Endpoint of the RDS PostgreSQL instance"
  value       = module.rds.rds_endpoint
}

output "eks_node_group_name" {
  description = "Name of the EKS node group"
  value       = module.eks_node_group.node_group_name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for Dagster logs"
  value       = module.cloudwatch.log_group_name
}

output "environment" {
  description = "Current Terraform workspace (dev or prod)"
  value       = terraform.workspace
}

output "pipeline_deployment_names" {
  description = "Names of the Kubernetes Deployments for the pipelines"
  value       = module.user_code.deployment_names
}

output "pipeline_service_names" {
  description = "Names of the Kubernetes Services for the pipelines"
  value       = module.user_code.service_names
}