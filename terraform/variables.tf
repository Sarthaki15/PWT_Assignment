variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "my-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/26"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/28"
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
  default     = "eu-north-1a"
}

variable "ecr_repo_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "my-ecr-repo"
}

variable "repository_type" {
  description = "Type of the ECR repository"
  type        = string
  default     = "public"
}

variable "allowed_account_id" {
  description = "AWS account ID allowed to pull images"
  type        = string
  default     = "170010887450"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "c7i-flex.large"
}

variable "key_name" {
  description = "The name of the key pair to use for the EC2 instance"
  type        = string
  default     = "sarth_key"
}

variable "instance_name" {
  description = "The name tag for the EC2 instance"
  type        = string
  default     = "my-ec2-instance"
}

variable "security_group_name" {
  type        = string
  description = "The name of the security group"
  default     = "sarth-terraform-sg"
}

variable "ssh_ingress_cidr" {
  type        = string
  description = "The CIDR block for SSH ingress"
  default     = "0.0.0.0/0"
}

variable "http_ingress_cidr" {
  type        = string
  description = "The CIDR block for HTTP ingress"
  default     = "0.0.0.0/0"
}

variable "https_ingress_cidr" {
  type        = string
  description = "The CIDR block for HTTPS ingress"
  default     = "0.0.0.0/0"
}

variable "rds_ingress_cidr" {
  type        = string
  description = "The CIDR block for RDS ingress"
  default     = "0.0.0.0/0"
}

variable "egress_cidr" {
  type        = string
  description = "The CIDR block for outbound traffic"
  default     = "0.0.0.0/0"
}