variable "ecr_repo_name" {
  type        = string
  description = "ECR repository name"
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, prod)"
}

variable "allowed_account_id" {
  type        = string
  description = "AWS account ID allowed to pull images"
}

variable "repository_type" {
  type        = string
  description = "Type of the ECR repository"
  default     = "private"
}