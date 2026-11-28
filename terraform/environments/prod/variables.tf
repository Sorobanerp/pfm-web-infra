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

variable "shared_state_bucket" {
  description = "S3 bucket storing pfm-shared-infra remote state"
  type        = string
  default     = "sorobanerp-pfm-tfstate-us-east-2-366476833548"
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

variable "desired_count" {
  description = "Scale-to-Zero Bootstrap desired ECS task count (0 during bootstrap)"
  type        = number
  default     = 0
}

variable "min_capacity" {
  description = "Scale-to-Zero Bootstrap minimum autoscaling capacity (0 during bootstrap)"
  type        = number
  default     = 0
}

variable "max_capacity" {
  description = "Scale-to-Zero Bootstrap maximum autoscaling capacity (0 during bootstrap)"
  type        = number
  default     = 0
}

variable "enable_cloudwatch_logs" {
  description = "Disable AWS CloudWatch Logs by default (FinOps ADR-010)"
  type        = bool
  default     = false
}
