output "subnet_id" {
  value = aws_subnet.main.id
}

output "subnet_arn" {
  value = aws_subnet.main.arn
}

output "subnet_vpc_id" {
  value = aws_subnet.main.vpc_id
}

output "subnet_cidr_block" {
  value = aws_subnet.main.cidr_block
}

output "subnet_availability_zone" {
  value = aws_subnet.main.availability_zone
}

output "subnet_availability_zone_id" {
  value = aws_subnet.main.availability_zone_id
}

output "subnet_owner_id" {
  value = aws_subnet.main.owner_id
}

output "subnet_ipv6_cidr_block_association_id" {
  value = aws_subnet.main.ipv6_cidr_block_association_id
}

output "subnet_assign_ipv6_address_on_creation" {
  value = aws_subnet.main.assign_ipv6_address_on_creation
}

output "subnet_map_public_ip_on_launch" {
  value = aws_subnet.main.map_public_ip_on_launch
}

output "subnet_private_dns_hostname_type_on_launch" {
  value = aws_subnet.main.private_dns_hostname_type_on_launch
}

output "subnet_enable_lni_at_device_index" {
  value = aws_subnet.main.enable_lni_at_device_index
}

output "subnet_tags" {
  value = aws_subnet.main.tags
}

output "subnet_tags_all" {
  value = aws_subnet.main.tags_all
}

output "subnet_name" {
  value = aws_subnet.main.tags["Name"]
}