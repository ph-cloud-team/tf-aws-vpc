output "vpc_id" {
  description = "ID of the VPC."
  value       = module.tf_aws_vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block allocated to the VPC."
  value       = module.tf_aws_vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by AZ."
  value       = module.tf_aws_vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs keyed by AZ."
  value       = module.tf_aws_vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs keyed by AZ."
  value       = module.tf_aws_vpc.nat_gateway_ids
}
