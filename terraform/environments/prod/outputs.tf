output "ecs_service_name" {
  description = "Provisioned Amazon ECS Service Name"
  value       = module.ecs_service.ecs_service_name
}

output "ecs_task_definition_arn" {
  description = "Provisioned Amazon ECS Task Definition ARN"
  value       = module.ecs_service.ecs_task_definition_arn
}

output "ecs_task_role_arn" {
  description = "Least-privilege IAM Task Role ARN"
  value       = module.ecs_service.ecs_task_role_arn
}
