# Module `ecs-service` (`pfm-web-infra`)

Módulo canônico OpenTofu (Padrão Terraform Docs) para provisionamento do serviço `pfm-web-nextjs` em Amazon ECS Fargate Spot Arm64 com AWS Cloud Map Service Connect (`pfm-web-nextjs.pfm.internal:3000`), IAM Roles Least-Privilege, Zero-CloudWatch (`enable_cloudwatch_logs = false`) e Scale-to-Zero Bootstrap (`desired_count = 0, min_capacity = 0, max_capacity = 0` com `count = var.max_capacity > 0 ? 1 : 0` no Application Auto Scaling).

## Inputs

| Name | Description | Type | Default |
| :--- | :--- | :---: | :---: |
| `environment` | Target deployment environment (`dev` or `prod`) | `string` | *(required)* |
| `aws_region` | Primary AWS Region | `string` | `"us-east-2"` |
| `compute_engine` | Compute engine (`ecs_fargate_spot` or `eks`) | `string` | `"ecs_fargate_spot"` |
| `service_name` | Microservice canonical name | `string` | `"pfm-web-nextjs"` |
| `image_repository` | Container image repository URI | `string` | `"public.ecr.aws/docker/library/busybox"` |
| `image_tag` | Container image tag | `string` | `"1.36"` |
| `desired_count` | Desired task count (`0` in bootstrap) | `number` | `0` |
| `min_capacity` | Minimum autoscaling capacity (`0` in bootstrap) | `number` | `0` |
| `max_capacity` | Maximum autoscaling capacity (`0` in bootstrap) | `number` | `0` |
| `enable_cloudwatch_logs` | Disable CloudWatch Logs by default (`ADR-010`) | `bool` | `false` |

## Outputs

| Name | Description | Sensitive |
| :--- | :--- | :---: |
| `ecs_service_name` | Provisioned Amazon ECS Service Name | `false` |
| `ecs_task_definition_arn` | Provisioned Amazon ECS Task Definition ARN | `false` |
| `ecs_task_role_arn` | Least-privilege IAM Task Role ARN | `false` |
| `ecs_execution_role_arn` | IAM Task Execution Role ARN | `false` |
