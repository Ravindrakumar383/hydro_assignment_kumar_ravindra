# Geospatial Pipeline Project

## Overview 

The `geospatial-pipeline` is a Dagster-based pipeline designed for processing geospatial field data. It identifies late-arriving data and stores it in Amazon S3 for backfill processing. The pipeline is deployed on an existing Amazon EKS (Elastic Kubernetes Service) cluster, with Dagster core components and pipeline-specific deployments separated for modularity and scalability. Infrastructure is managed using Terraform, supporting `dev` and `prod` environments through environment-specific variables.

## Deployment on EKS Cluster

### Assumptions

- An existing EKS cluster is available in AWS.
- Required AWS credentials and Kubernetes configurations are properly set up.
- there is exiting s3 bcuket to store teraform state
### Setup Thought Process

- **EKS Cluster**: Leverage an existing EKS cluster to host Dagster components, including deployments for Dagster core (Dagit and Dagster daemon) and the geospatial pipeline.
- **Terraform Variables**: Define `dev` and `prod` variables to manage environment-specific configurations, such as S3 bucket names, prefixes, and logging levels.
- **Deployment Separation**:
  - **Dagster Core**: Deploy Dagit (web UI) and the Dagster daemon as a stable, reusable base layer.
  - **Pipeline**: Deploy the geospatial pipeline code independently, enabling isolated updates and scaling without affecting the core. And can deploy multiple pipleines or seprately 
- **ConfigMap as Volume**: Use a Kubernetes ConfigMap mounted as a volume to share configuration settings  across deployments, ensuring consistency and flexibility.

### Implementation

1. **Terraform Configuration**:
   - Define `dev` and `prod` variables and set up an S3 bucket for Terraform state:
     ```terraform
     variable "resource_prefix" {
       description = "Prefix for resource names"
       default     = "geospatial"
     }

     locals {
       env             = terraform.workspace  # "dev" or "prod"
       resource_prefix = "${var.resource_prefix}-${local.env}"
       s3_bucket       = "${var.resource_prefix}-${local.env}-data"
       s3_prefix       = "geospatial-data"
     }
     ```
   - Create a ConfigMap for pipeline configuration:
     ```terraform
     resource "kubernetes_config_map" "geospatial_pipeline_config" {
       metadata {
         name = "geospatial-pipeline-config"
       }
       data = {
         "config.yaml" = <<-EOT
           s3_bucket: "${local.s3_bucket}"
           s3_prefix: "${local.s3_prefix}"
           log_level: "INFO"
         EOT
       }
     }
     ```

2. **Dagster Core Deployment**:
   - Deploy Dagster core components using Helm on the EKS cluster:
     ```terraform
     resource "helm_release" "dagster_core" {
       name       = "dagster-core"
       chart      = "dagster"
       repository = "https://dagster-io.github.io/helm"
       namespace  = "dagster"
       set {
         name  = "dagster-user-deployments.enabled"
         value = "false"  # Disable user deployments in core chart
       }
       set {
         name  = "dagit.pod.volumes[0].name"
         value = "config-volume"
       }
       set {
         name  = "dagit.pod.volumes[0].configMap.name"
         value = "geospatial-pipeline-config"
       }
       set {
         name  = "dagit.pod.volumeMounts[0].name"
         value = "config-volume"
       }
       set {
         name  = "dagit.pod.volumeMounts[0].mountPath"
         value = "/etc/dagster/config"
       }
     }
     ```

3. **Pipeline Deployment**:
   - Deploy the geospatial pipeline as a separate Kubernetes deployment:
     ```terraform
     resource "kubernetes_deployment" "geospatial_pipeline" {
       metadata {
         name      = "geospatial-pipeline-deployment"
         namespace = "dagster"
       }
       spec {
         replicas = 1
         selector {
           match_labels = { app = "geospatial-pipeline" }
         }
         template {
           metadata {
             labels = { app = "geospatial-pipeline" }
           }
           spec {
             container {
               name  = "geospatial-pipeline"
               image = "geospatial-pipeline:latest"
               volume_mount {
                 name      = "config-volume"
                 mount_path = "/etc/dagster/config"
               }
             }
             volume {
               name = "config-volume"
               config_map {
                 name = "geospatial-pipeline-config"
               }
             }
           }
         }
       }
     }
     ```

## Late Arrival Logic and S3 Storage

### Logic

- **Daily Partitions**: Data is partitioned daily (e.g., `2025-01-01`) using Dagster’s `DailyPartitionsDefinition`.
- **Late Arrival Definition**:
  - A field is considered late if `arrival_time > processing_date + 1 day` (relative to its intended partition).
  - Alternatively, a field is late if it arrives after the current partition’s processing window.
- **Handling**:
  - Late fields are skipped during current partition processing.
  - They are stored in S3 at `late_data/{intended_partition_date}/{field_id}.txt` for later backfill processing.

### Implementation

- **Late Arrival Check** (example in Python/Dagster):
  ```python
  from datetime import timedelta

  def process_fields(self, partition_date, arrival_time, intended_partition_date, context):
      late_fields = []
      has_late_data = False
      partition_dt = self._parse_partition_datetime(partition_date)

      if intended_partition_date != partition_date:
          intended_partition_dt = self._parse_partition_datetime(intended_partition_date)
          if arrival_time > intended_partition_dt + timedelta(days=1):
              has_late_data = True
              late_field = {"field_id": "example_field", "data": "example_data"}
              late_fields.append(late_field)
              self._store_late_data(late_field, intended_partition_date, context)
              return  # Skip processing this field
      if self._is_late_arrival(arrival_time, partition_dt):
          has_late_data = True
          late_field = {"field_id": "example_field", "data": "example_data"}
          late_fields.append(late_field)
          self._store_late_data(late_field, intended_partition_date, context)
  ```
- **S3 Storage**:
  ```python
  def _store_late_data(self, late_field, intended_partition_date, context):
      s3_key = f"late_data/{intended_partition_date}/{late_field['field_id']}.txt"
      message = f"Late field: {late_field['field_id']} for partition {intended_partition_date}"
      self.s3_io_manager._write(message, s3_key)
      context.log.info(f"Stored late data at s3://{self.s3_io_manager.bucket}/{s3_key}")
  ```

## Pydantic Validation

- **Purpose**: Ensure input data integrity (e.g., `arrival_time`, `processing_date`) using Pydantic models.
- **Model Example**:
  ```python
  from pydantic import BaseModel, Field
  from datetime import datetime

  class RawFieldData(BaseModel):
      field_id: str = Field(..., min_length=1)
      arrival_time: datetime = Field(..., format="YYYY-MM-DDTHH:MM:SS")
      processing_date: datetime = Field(..., format="YYYY-MM-DDTHH:MM:SS")
      data: dict
  ```

## Running the Pipeline

1. **Install Poetry**:
   - Install Poetry if not already present:
     ```bash
     curl -sSL https://install.python-poetry.org | python3 -
     ```
   - Add Poetry to PATH (if needed):
     ```bash
     export PATH="$HOME/.local/bin:$PATH"
     ```

2. **Install Dependencies with Poetry**:
   - Navigate to the project directory:
     ```bash
     cd pipelines/geospatial_pipeline
     ```
   - Install dependencies:
     ```bash
     poetry install --with test --no-root
     ```

3. **Deploy with Terraform**:
   - Initialize Terraform:
     ```bash
     terraform init
     ```
   - Apply configuration for the desired environment:
     ```bash
     terraform apply -var="environment=dev"
     ```

4. **Run Tests**:
   - Execute the test suite:
     ```bash
     poetry run pytest tests/ -v
     ```

---



