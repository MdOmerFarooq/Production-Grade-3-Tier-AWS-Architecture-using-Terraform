output "vpc_id" {
  value = aws_vpc.VPC.id
}

output "vpc_name" {
  value = aws_vpc.VPC.tags["Name"]
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "public_route_tableid" {
  value = aws_route_table.public_rt.id
}

output "private_frontend_subnet_ids" {
  value = aws_subnet.private_frontend[*].id
}

output "private_backend_subnet_ids" {
  value = aws_subnet.private_backend[*].id   
}

output "private_subnets_route_tableid" {
  value = aws_route_table.private_rt.id
}

output "private_db_subnet_ids" {
  value = aws_subnet.private_db[*].id 
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gw.id
}

output "nat_gateway_eip" {
  value = aws_eip.nat_eip.public_ip
}