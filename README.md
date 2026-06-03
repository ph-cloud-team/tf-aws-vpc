# tf-aws-vpc

Enterprise Terraform module for creating an IPAM-backed AWS VPC with public/private subnet tiers, controlled egress, and baseline NAT monitoring.

## What This Module Creates

- VPC allocated from AWS VPC IPAM
- Public subnets across selected Availability Zones
- Private subnets across selected Availability Zones
- Internet Gateway
- Public route table
- Private route tables
- Optional NAT Gateway egress
- NAT Gateway CloudWatch alarm baseline

## Enterprise Defaults

- VPC CIDR is allocated from IPAM.
- DNS support and DNS hostnames are enabled.
- Subnets do not auto-assign public IPv4 addresses.
- One NAT Gateway is enabled by default for cost-conscious dev/lab environments.
- NAT Gateway has a CloudWatch alarm for `ErrorPortAllocation`.
- Required enterprise tags are validated and propagated.

## Usage

```hcl
module "vpc" {
  source  = "gitlab.midhtech.local/cloud_team/tf-modules/aws/network/tf-aws-vpc/aws"
  version = "1.0.0"

  name                = "dev-eks-vpc"
  ipv4_ipam_pool_id   = module.ipam_pool.ipam_pool_id
  ipv4_netmask_length = 20
  availability_zones  = ["us-east-1a", "us-east-1b"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name               = "dev-eks-vpc"
    Environment        = "dev"
    Owner              = "platform-team"
    CostCenter         = "shared-services"
    Application        = "eks-platform"
    DataClassification = "internal"
  }
}
```

## Inputs

| Name | Description | Default |
| --- | --- | --- |
| `name` | Name prefix for VPC resources | required |
| `ipv4_ipam_pool_id` | IPAM pool ID used for VPC allocation | required |
| `ipv4_netmask_length` | VPC netmask allocation size | `20` |
| `availability_zones` | AZs for subnet placement | required |
| `public_subnet_newbits` | Additional subnet bits for public subnets | `4` |
| `private_subnet_newbits` | Additional subnet bits for private subnets | `4` |
| `enable_dns_support` | Enable VPC DNS support | `true` |
| `enable_dns_hostnames` | Enable VPC DNS hostnames | `true` |
| `enable_internet_gateway` | Create an Internet Gateway | `true` |
| `enable_nat_gateway` | Create NAT Gateway egress | `true` |
| `single_nat_gateway` | Use one NAT Gateway instead of one per AZ | `true` |
| `nat_gateway_alarm_actions` | NAT alarm action ARNs | `[]` |
| `tags` | Required enterprise tags | required |

## Outputs

| Name | Description |
| --- | --- |
| `vpc_id` | VPC ID |
| `vpc_cidr_block` | IPAM-allocated VPC CIDR |
| `public_subnet_ids` | Public subnet IDs keyed by AZ |
| `private_subnet_ids` | Private subnet IDs keyed by AZ |
| `private_route_table_ids` | Private route table IDs keyed by AZ |
| `nat_gateway_ids` | NAT Gateway IDs keyed by AZ |
| `nat_gateway_alarm_names` | NAT Gateway alarm names keyed by AZ |

## Policy Coverage

This module is designed to satisfy:

- `aws/network/ipam-required.rego`
- `aws/network/no-hardcoded-cidr.rego`
- `aws/network/subnet-standards.rego`
- `aws/network/nat-gateway-standards.rego`
- `aws/cloudwatch/metric-alarms-required.rego`
- `aws/common/required-tags.rego`
- `aws/common/naming-standards.rego`
- `aws/common/data-classification.rego`

## Documentation

- [Architecture](docs/architecture.md)
- [Security](docs/security.md)
- [Usage](docs/usage.md)
