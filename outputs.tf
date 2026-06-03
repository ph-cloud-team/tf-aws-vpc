############################################
# Outputs for tf-aws-vpc
############################################

output "module_name" {
  description = "Name of the Terraform module."
  value       = local.module_name
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block allocated to the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets keyed by availability zone."
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}

output "private_subnet_ids" {
  description = "IDs of private subnets keyed by availability zone."
  value       = { for az, subnet in aws_subnet.private : az => subnet.id }
}

output "public_route_table_id" {
  description = "Public route table ID."
  value       = try(aws_route_table.public[0].id, null)
}

output "private_route_table_ids" {
  description = "Private route table IDs keyed by availability zone."
  value       = { for az, route_table in aws_route_table.private : az => route_table.id }
}

output "internet_gateway_id" {
  description = "Internet gateway ID when created."
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs keyed by availability zone."
  value       = { for az, nat in aws_nat_gateway.this : az => nat.id }
}

output "nat_gateway_alarm_names" {
  description = "NAT Gateway CloudWatch alarm names keyed by availability zone."
  value       = { for az, alarm in aws_cloudwatch_metric_alarm.nat_gateway_error_port_allocation : az => alarm.alarm_name }
}

output "default_security_group_id" {
  description = "ID of the restricted default security group managed for the VPC."
  value       = aws_default_security_group.this.id
}

output "flow_log_id" {
  description = "ID of the VPC Flow Log when enabled."
  value       = try(aws_flow_log.this[0].id, null)
}

output "flow_log_group_name" {
  description = "CloudWatch log group name used for VPC Flow Logs."
  value       = try(aws_cloudwatch_log_group.vpc_flow_logs[0].name, null)
}

output "flow_log_role_arn" {
  description = "IAM role ARN used by VPC Flow Logs."
  value       = try(aws_iam_role.flow_logs[0].arn, null)
}
