output "ecs_service_name" {
  description = "Provisioned Amazon ECS Service Name"
  value       = try(aws_ecs_service.service[0].name, "")
}

output "ecs_task_definition_arn" {
  description = "Provisioned Amazon ECS Task Definition ARN"
  value       = try(aws_ecs_task_definition.service[0].arn, "")
}

output "ecs_task_role_arn" {
  description = "Least-privilege IAM Task Role ARN"
  value       = try(aws_iam_role.ecs_task_role[0].arn, "")
}

output "ecs_execution_role_arn" {
  description = "IAM Task Execution Role ARN"
  value       = try(aws_iam_role.ecs_execution_role[0].arn, "")
}
