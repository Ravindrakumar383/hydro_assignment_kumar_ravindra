output "deployment_names" {
  description = "Names of the Kubernetes Deployments for the user code"
  value       = { for name, _ in var.pipeline_configs : name => kubernetes_deployment.user_code[name].metadata[0].name }
}

output "service_names" {
  description = "Names of the Kubernetes Services for the user code"
  value       = { for name, _ in var.pipeline_configs : name => kubernetes_service.user_code[name].metadata[0].name }
}