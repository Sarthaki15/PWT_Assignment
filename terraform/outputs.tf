output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = module.vpc.subnet_id
}

output "route_table_id" {
  description = "The ID of the route table"
  value       = module.vpc.route_table_id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = module.vpc.internet_gateway_id
}

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "ec2_instance_public_ip" {
  value = module.ec2.instance_public_ip
}

output "ec2_instance_key_name" {
  value = module.ec2.instance_key_name
}

output "security_group_id" {
  value = module.security_groups.security_group_id
}

output "security_group_name" {
  value = module.security_groups.security_group_name
}