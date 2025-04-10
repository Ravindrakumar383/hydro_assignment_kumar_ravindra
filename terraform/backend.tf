terraform {
  backend "s3" {
    bucket         = "hydrosat-central-central-terraform-state" # keeping hardcoded if central or can override during init
    key            = "dagster-eks/${terraform.workspace}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true     
    workspace_key_prefix = "geosaptial-pipeline"
  }
}
