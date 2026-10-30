variable "security_group_name" {
  type        = string
  description = "The name of the security group"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the security group will be created"
}

variable "ssh_ingress_cidr" {
  type        = string
  description = "The CIDR block for SSH ingress"
}

variable "http_ingress_cidr" {
  type        = string
  description = "The CIDR block for HTTP ingress"
}

variable "https_ingress_cidr" {
  type        = string
  description = "The CIDR block for HTTPS ingress"
}

variable "rds_ingress_cidr" {
  type        = string
  description = "The CIDR block for RDS ingress"
}

variable "egress_cidr" {
  type        = string
  description = "The CIDR block for outbound traffic"
}