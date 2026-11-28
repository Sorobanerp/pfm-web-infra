variable "environment" {
  description = "Target deployment environment (dev or prod)"
  type        = string
}

variable "aws_region" {
  description = "Primary AWS Region (Ohio)"
  type        = string
  default     = "us-east-2"
}

variable "compute_engine" {
  description = "Compute engine for workloads: ecs_fargate_spot (ADR-008) or eks"
  type        = string
  default     = "ecs_fargate_spot"
}

variable "service_name" {
  description = "Microservice canonical name"
  type        = string
  default     = "pfm-web-nextjs"
}

variable "image_repository" {
  description = "Container image repository URI"
  type        = string
  default     = "public.ecr.aws/docker/library/busybox"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "1.36"
}

variable "container_port" {
  description = "Container listening TCP port"
  type        = number
  default     = 3000
}

variable "port_name" {
  description = "Service Connect port mapping name (http or grpc)"
  type        = string
  default     = "http"
}

variable "cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Fargate task memory in MiB"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Scale-to-Zero Bootstrap desired ECS task count (0 during bootstrap; 1 after ECR push)"
  type        = number
  default     = 0
}

variable "min_capacity" {
  description = "Scale-to-Zero Bootstrap minimum autoscaling capacity (0 during bootstrap; 1 after ECR push)"
  type        = number
  default     = 0
}

variable "max_capacity" {
  description = "Scale-to-Zero Bootstrap maximum autoscaling capacity (0 during bootstrap; 1 in dev, 3 in prod)"
  type        = number
  default     = 0
}

variable "enable_cloudwatch_logs" {
  description = "Disable AWS CloudWatch Logs by default (FinOps ADR-010 Zero-CloudWatch)"
  type        = bool
  default     = false
}

variable "ecs_cluster_arn" {
  description = "Shared ECS Cluster ARN from pfm-shared-infra"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Shared ECS Cluster Name from pfm-shared-infra"
  type        = string
}

variable "ecs_tasks_security_group_id" {
  description = "Shared ECS Tasks Security Group ID from pfm-shared-infra"
  type        = string
  default     = ""
}

variable "cloud_map_namespace_arn" {
  description = "Shared AWS Cloud Map namespace ARN (pfm.internal)"
  type        = string
  default     = ""
}

variable "task_subnet_ids" {
  description = "Subnet IDs for ECS Fargate tasks"
  type        = list(string)
  default     = []
}

variable "kms_master_key_arn" {
  description = "Shared KMS Master Key ARN from pfm-shared-infra"
  type        = string
  default     = ""
}

variable "rds_resource_id" {
  description = "Shared RDS PostgreSQL 16 resource ID for IAM DB authentication"
  type        = string
  default     = "db-PFMCORELEDGER01"
}

variable "statements_bucket_name" {
  description = "Encrypted S3 bucket name for credit card statements"
  type        = string
  default     = ""
}

variable "statements_bucket_arn" {
  description = "Encrypted S3 bucket ARN for credit card statements"
  type        = string
  default     = ""
}

variable "datadog_api_key_secret_arn" {
  description = "Secrets Manager ARN for Datadog API Key (ADR-010)"
  type        = string
  default     = ""
}
