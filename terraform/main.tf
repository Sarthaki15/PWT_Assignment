module "vpc" {
  source            = "./modules/vpc"
  vpc_name          = var.vpc_name
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  availability_zone = var.availability_zone
}

module "ecr" {
  source             = "./modules/ecr"
  ecr_repo_name      = var.ecr_repo_name
  repository_type    = var.repository_type
  environment        = var.environment
  allowed_account_id = var.allowed_account_id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

module "security_groups" {
  source              = "./modules/security_group"
  security_group_name = var.security_group_name
  vpc_id              = module.vpc.vpc_id
  ssh_ingress_cidr    = var.ssh_ingress_cidr
  http_ingress_cidr   = var.http_ingress_cidr
  https_ingress_cidr  = var.https_ingress_cidr
  rds_ingress_cidr    = var.rds_ingress_cidr
  egress_cidr         = var.egress_cidr
}

module "ec2" {
  source                = "./modules/ec2"
  vpc_security_group_id = module.security_groups.security_group_id
  subnet_id             = module.vpc.subnet_id
  ami_id                = data.aws_ami.ubuntu.id
  instance_type         = var.instance_type
  key_name              = var.key_name
  instance_name         = var.instance_name
}
