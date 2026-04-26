output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "vpc_instance_tenancy" {
  value = aws_vpc.main.instance_tenancy
}

output "vpc_default_network_acl_id" {
  value = aws_vpc.main.default_network_acl_id
}

output "vpc_default_route_table_id" {
  value = aws_vpc.main.default_route_table_id
}

output "vpc_default_security_group_id" {
  value = aws_vpc.main.default_security_group_id
}

output "vpc_dhcp_options_id" {
  value = aws_vpc.main.dhcp_options_id
}

output "vpc_ipv6_association_id" {
  value = aws_vpc.main.ipv6_association_id
}

output "vpc_owner_id" {
  value = aws_vpc.main.owner_id
}

output "vpc_tags_all" {
  value = aws_vpc.main.tags_all
}

output "vpc_name" {
  value = aws_vpc.main.tags["Name"]
}