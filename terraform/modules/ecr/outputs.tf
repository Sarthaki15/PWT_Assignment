output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.my_ecr_repo.name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.my_ecr_repo.repository_url
}

output "ecr_registry_id" {
  description = "AWS account ID associated with the repository"
  value       = aws_ecr_repository.my_ecr_repo.registry_id
}