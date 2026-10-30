output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.my_vpc.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.my_subnet.id
}

output "route_table_id" {
  description = "The ID of the route table"
  value       = aws_route_table.my_route_table.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.my_igw.id
}