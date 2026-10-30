# Lifecycle Policy Document
locals {
  ecr_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the latest 100 dev images"

        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["dev"]
          countType     = "imageCountMoreThan"
          countNumber   = 100
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

# IAM Repository Policy
data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "AllowAccountPullAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.allowed_account_id}:root"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

resource "aws_ecr_repository" "my_ecr_repo" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = var.ecr_repo_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Attach Repository Policy
resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.my_ecr_repo.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}

# Attach Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "example" {
  repository = aws_ecr_repository.my_ecr_repo.name
  policy     = local.ecr_lifecycle_policy
}