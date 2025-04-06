resource "kubernetes_deployment" "user_code" {
  for_each = var.pipeline_configs

  metadata {
    name      = "dagster-user-code-${each.value.name}"
    namespace = var.namespace
    labels = {
      app = "dagster-user-code-${each.value.name}"
    }
  }
  spec {
    replicas = each.value.replicas
    selector {
      match_labels = {
        app = "dagster-user-code-${each.value.name}"
      }
    }
    template {
      metadata {
        labels = {
          app = "dagster-user-code-${each.value.name}"
        }
      }
      spec {
        service_account_name = var.service_account_name
        container {
          name  = "user-code"
          image = "${var.ecr_repository_url}/my-dagster-${each.value.name}:${var.image_tag}"
          port {
            container_port = each.value.port
          }
          resources {
            requests = {
              cpu    = each.value.cpu_request
              memory = each.value.memory_request
            }
            limits = {
              cpu    = each.value.cpu_limit
              memory = each.value.memory_limit
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "user_code" {
  for_each = var.pipeline_configs

  metadata {
    name      = "dagster-user-code-${each.value.name}"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "dagster-user-code-${each.value.name}"
    }
    port {
      port        = each.value.port
      target_port = each.value.port
    }
    type = "ClusterIP"
  }
}