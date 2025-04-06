resource "aws_iam_role" "dagster_s3_role" {
  name = "${var.resource_prefix}-dagster-s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer}:sub" = "system:serviceaccount:${var.namespace}:dagster-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  role = aws_iam_role.dagster_s3_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:*"]
      Resource = ["arn:aws:s3:::${var.s3_bucket_name}/*"]
    }]
  })
}

resource "aws_iam_role_policy" "cloudwatch_access" {
  role = aws_iam_role.dagster_s3_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups"
      ]
      Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${var.log_group_name}:*"
    }]
  })
}

resource "kubernetes_service_account" "dagster_sa" {
  metadata {
    name      = "dagster-sa"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.dagster_s3_role.arn
    }
  }
}

resource "helm_release" "dagster" {
  name       = "dagster"
  repository = "https://dagster-io.github.io/helm"
  chart      = "dagster"
  namespace  = var.namespace
  create_namespace = true

  values = [yamlencode({
    global = {
      postgresql = {
        postgresqlHost     = split(":", var.rds_endpoint)[0]
        postgresqlUsername = "dagster"
        postgresqlPassword = var.db_password
        postgresqlDatabase = "dagster"
        postgresqlPort     = 5432
      }
    }
    dagsterWebserver = {
      replicaCount = var.webserver_replica_count
      resources = {
        requests = { cpu = var.webserver_cpu_request, memory = var.webserver_memory_request }
        limits   = { cpu = var.webserver_cpu_limit, memory = var.webserver_memory_limit }
      }
      autoscaling = {
        enabled                        = true
        minReplicas                    = var.webserver_min_replicas
        maxReplicas                    = var.webserver_max_replicas
        targetCPUUtilizationPercentage = var.webserver_target_cpu_utilization
      }
      service = {
        type = "LoadBalancer"
        port = 3000
      }
      # Mount the ConfigMap for user deployments
      extraVolumes = [
        {
          name = "user-deployments-config"
          configMap = {
            name = "dagster-user-deployments"
          }
        }
      ]
      extraVolumeMounts = [
        {
          name      = "user-deployments-config"
          mountPath = "/opt/dagster/dagster.yaml"
          subPath   = "deployments.yaml"
        }
      ]
    }
    dagsterDaemon = {
      replicaCount = var.daemon_replica_count
      resources = {
        requests = { cpu = var.daemon_cpu_request, memory = var.daemon_memory_request }
        limits   = { cpu = var.daemon_cpu_limit, memory = var.daemon_memory_limit }
      }
      autoscaling = {
        enabled                        = true
        minReplicas                    = var.daemon_min_replicas
        maxReplicas                    = var.daemon_max_replicas
        targetCPUUtilizationPercentage = var.daemon_target_cpu_utilization
      }
      runCoordinator = {
        enabled = true
        module  = "dagster_k8s"
        class   = "K8sRunLauncher"
      }
      # Mount the ConfigMap for user deployments
      extraVolumes = [
        {
          name = "user-deployments-config"
          configMap = {
            name = "dagster-user-deployments"
          }
        }
      ]
      extraVolumeMounts = [
        {
          name      = "user-deployments-config"
          mountPath = "/opt/dagster/dagster.yaml"
          subPath   = "deployments.yaml"
        }
      ]
    }
    dagster-user-deployments = {
      enabled = false  # Disable built-in user deployments
    }
    computeLogs = {
      module = "dagster_aws.cloudwatch.compute_log_manager"
      class  = "CloudWatchComputeLogManager"
      config = {
        log_group = var.log_group_name
        region    = var.aws_region
      }
    }
    runStorage = {
      module = "dagster_aws.s3.intermediate_store"
      class  = "S3IntermediateStore"
      config = {
        s3_bucket = var.s3_bucket_name
      }
    }
    serviceAccount = {
      create = false
      name   = kubernetes_service_account.dagster_sa.metadata[0].name
    }
  })]

  depends_on = [var.node_group_name]
}