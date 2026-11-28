provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket = var.shared_state_bucket
    key    = "pfm-shared/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

locals {
  default_cluster_name        = var.environment == "prod" ? "pfm-ecs-pilot" : "pfm-ecs-pilot-${var.environment}"
  ecs_cluster_arn             = try(data.terraform_remote_state.shared.outputs.ecs_cluster_arn, "arn:aws:ecs:${var.aws_region}:366476833548:cluster/${local.default_cluster_name}")
  ecs_cluster_name            = try(data.terraform_remote_state.shared.outputs.ecs_cluster_name, local.default_cluster_name)
  ecs_tasks_security_group_id = try(data.terraform_remote_state.shared.outputs.ecs_tasks_security_group_id, "")
  cloud_map_namespace_arn     = try(data.terraform_remote_state.shared.outputs.cloud_map_namespace_arn, "")
  public_subnet_ids           = try(data.terraform_remote_state.shared.outputs.public_subnet_ids, [])
  private_subnet_ids          = try(data.terraform_remote_state.shared.outputs.private_subnet_ids, [])
  task_subnet_ids             = length(local.public_subnet_ids) > 0 ? local.public_subnet_ids : local.private_subnet_ids
  kms_master_key_arn          = try(data.terraform_remote_state.shared.outputs.kms_master_key_arn, "arn:aws:kms:${var.aws_region}:366476833548:alias/pfm-master-key")
  rds_resource_id             = try(data.terraform_remote_state.shared.outputs.rds_resource_id, "db-PFMCORELEDGER01")
  statements_bucket_name      = try(data.terraform_remote_state.shared.outputs.s3_statements_bucket, "pfm-statements-encrypted-${var.environment}")
  statements_bucket_arn       = try(data.terraform_remote_state.shared.outputs.s3_statements_bucket_arn, "arn:aws:s3:::pfm-statements-encrypted-${var.environment}")
  datadog_api_key_secret_arn  = try(data.terraform_remote_state.shared.outputs.datadog_api_key_secret_arn, "arn:aws:secretsmanager:${var.aws_region}:*:secret:pfm/${var.environment}/datadog/api-key-*")
}

module "ecs_service" {
  source                      = "../../modules/ecs-service"
  environment                 = var.environment
  aws_region                  = var.aws_region
  compute_engine              = var.compute_engine
  service_name                = "pfm-web-nextjs"
  image_repository            = var.image_repository
  image_tag                   = var.image_tag
  desired_count               = var.desired_count
  min_capacity                = var.min_capacity
  max_capacity                = var.max_capacity
  enable_cloudwatch_logs      = var.enable_cloudwatch_logs
  ecs_cluster_arn             = local.ecs_cluster_arn
  ecs_cluster_name            = local.ecs_cluster_name
  ecs_tasks_security_group_id = local.ecs_tasks_security_group_id
  cloud_map_namespace_arn     = local.cloud_map_namespace_arn
  task_subnet_ids             = local.task_subnet_ids
  kms_master_key_arn          = local.kms_master_key_arn
  rds_resource_id             = local.rds_resource_id
  statements_bucket_name      = local.statements_bucket_name
  statements_bucket_arn       = local.statements_bucket_arn
  datadog_api_key_secret_arn  = local.datadog_api_key_secret_arn
}
