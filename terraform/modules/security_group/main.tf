resource "aws_security_group" "my_terraform_sg" {
  name        = var.security_group_name
  vpc_id      = var.vpc_id
  description = "Security group for my Terraform EC2 instance"
  tags = {
    Name = var.security_group_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.my_terraform_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.ssh_ingress_cidr
  description       = "Allow SSH access from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.my_terraform_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.http_ingress_cidr
  description       = "Allow HTTP access from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.my_terraform_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.https_ingress_cidr
  description       = "Allow HTTPS access from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "allow_rds" {
  security_group_id = aws_security_group.my_terraform_sg.id
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "tcp"
  cidr_ipv4         = var.rds_ingress_cidr
  description       = "Allow custom port access from specified CIDR"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.my_terraform_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.egress_cidr
  description       = "Allow all outbound traffic"
}