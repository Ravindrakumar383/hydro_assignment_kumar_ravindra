output "webserver_url" {
  description = "URL to access the Dagster webserver (Dagit UI)"
  value       = "http://${data.kubernetes_service.dagster_webserver.status[0].load_balancer[0].ingress[0].hostname}:3000"
}

output "namespace" {
  description = "Kubernetes namespace where Dagster is deployed"
  value       = var.namespace
}

output "helm_release_status" {
  description = "Status of the Dagster Helm release"
  value       = helm_release.dagster.status
}

output "service_account_name" {
  description = "Name of the Kubernetes Service Account used by Dagster"
  value       = kubernetes_service_account.dagster_sa.metadata[0].name
}

data "kubernetes_service" "dagster_webserver" {
  metadata {
    name      = "dagster-dagster-webserver"
    namespace = var.namespace
  }
  depends_on = [helm_release.dagster]
}