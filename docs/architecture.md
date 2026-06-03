# Architecture

## Resource Model

The module creates a complete VPC baseline for private workload platforms:

- `aws_vpc.this` allocates the VPC CIDR from AWS VPC IPAM.
- `aws_subnet.public` creates public subnet tiers.
- `aws_subnet.private` creates private subnet tiers.
- `aws_internet_gateway.this` supports controlled internet routing.
- `aws_nat_gateway.this` provides private subnet egress.
- `aws_route_table.*` and associations wire public and private subnet routing.
- `aws_cloudwatch_metric_alarm.nat_gateway_error_port_allocation` provides NAT monitoring.

## NAT Design

`single_nat_gateway = true` is the default for lab and dev cost control. Production environments can set it to `false` to create a NAT Gateway per AZ when higher availability is required.

## Module Boundaries

This module does not create EKS clusters, VPC endpoints, security groups, DNS zones, transit routing, or inspection firewalls. Those concerns stay in separate modules and compose through `tf-live`.
