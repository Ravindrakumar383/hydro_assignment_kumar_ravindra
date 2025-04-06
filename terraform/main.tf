locals {
  env = terraform.workspace  # "dev" or "prod"
  resource_prefix = "${var.resource_prefix}-${local.env}"
}



module "secrets" {
  source         = "./modules/secrets"
  resource_prefix = local.resource_prefix
}

module "eks_node_group" {
  source          = "./modules/eks-node-group"
  eks_cluster_name = var.eks_cluster_name
  resource_prefix  = local.resource_prefix
  subnet_ids       = var.subnet_ids
  instance_types   = var.node_group_instance_types
  desired_size     = var.node_group_desired_size
  min_size         = var.node_group_min_size
  max_size         = var.node_group_max_size
}

module "s3" {
  source         = "./modules/s3"
  resource_prefix = local.resource_prefix
}

module "rds" {
  source            = "./modules/rds"
  resource_prefix   = local.resource_prefix
  subnet_ids        = var.subnet_ids
  db_password       = module.secrets.db_password
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  multi_az          = var.rds_multi_az
}

module "cloudwatch" {
  source            = "./modules/cloudwatch"
  resource_prefix   = local.resource_prefix
  log_retention_days = var.log_retention_days
}

module "dagster_helm" {
  source                 = "./modules/dagster-helm"
  namespace              = var.namespace
  rds_endpoint           = module.rds.rds_endpoint
  db_password            = module.secrets.db_password
  resource_prefix        = local.resource_prefix
  aws_region             = var.aws_region
  log_group_name         = module.cloudwatch.log_group_name
  node_group_name        = module.eks_node_group.node_group_name
  s3_bucket_name         = module.s3.bucket_name
  webserver_replica_count = var.webserver_replica_count
  webserver_cpu_request  = var.webserver_cpu_request
  webserver_memory_request = var.webserver_memory_request
  webserver_cpu_limit    = var.webserver_cpu_limit
  webserver_memory_limit = var.webserver_memory_limit
  webserver_min_replicas = var.webserver_min_replicas
  webserver_max_replicas = var.webserver_max_replicas
  webserver_target_cpu_utilization = var.webserver_target_cpu_utilization
  daemon_replica_count   = var.daemon_replica_count
  daemon_cpu_request     = var.daemon_cpu_request
  daemon_memory_request  = var.daemon_memory_request
  daemon_cpu_limit       = var.daemon_cpu_limit
  daemon_memory_limit    = var.daemon_memory_limit
  daemon_min_replicas    = var.daemon_min_replicas
  daemon_max_replicas    = var.daemon_max_replicas
  daemon_target_cpu_utilization = var.daemon_target_cpu_utilization
}

# Create a ConfigMap for user code deployments
resource "kubernetes_config_map" "user_deployments" {
  metadata {
    name      = "dagster-user-deployments"
    namespace = var.namespace
  }

  data = {
    "deployments.yaml" = yamlencode([
      for name, config in var.pipeline_configs : {
        name   = config.name
        service = "dagster-user-code-${config.name}"
        port   = config.port
      }
    ])
  }

  depends_on = [module.dagster_helm]
}

module "user_code" {
  source             = "./modules/user-code"
  namespace          = var.namespace
  ecr_repository_url = var.ecr_repository_url
  pipeline_configs   = var.pipeline_configs
  service_account_name = "dagster-sa"
  depends_on         = [module.dagster_helm, kubernetes_config_map.user_deployments]
}