output "vpc_id" {
  description = "ID of the VPC."
  value       = module.tf_aws_vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block allocated to the VPC."
  value       = module.tf_aws_vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "Private subnet IDs keyed by AZ."
  value       = module.tf_aws_vpc.private_subnet_ids
}
