# =============================================================================
# pfm-web-infra — Environment: prod
# ADR-009: Scale-to-Zero Bootstrap (desired=0, min=0, max=0)
# Target post-ECR image push (FEAT-02/FEAT-03): desired=1, min=1, max=3
# =============================================================================
environment            = "prod"
aws_region             = "us-east-2"
compute_engine         = "ecs_fargate_spot"
enable_cloudwatch_logs = false
desired_count          = 0 # Post-ECR rollout target: 1
min_capacity           = 0 # Post-ECR rollout target: 1
max_capacity           = 0 # Post-ECR rollout target: 3
