# Usage

## Minimal Example

```hcl
module "vpc" {
  source = "../../"

  name                = "dev-eks-vpc"
  ipv4_ipam_pool_id   = "ipam-pool-0123456789abcdef0"
  ipv4_netmask_length = 20
  availability_zones  = ["us-east-1a", "us-east-1b"]

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

## Downstream Consumers

Downstream modules should consume:

- `vpc_id` for EKS, security groups, and VPC endpoints.
- `private_subnet_ids` for EKS control plane subnet placement and managed node groups.
- `public_subnet_ids` for NAT Gateway and public-facing load balancer subnets when required.
- `private_route_table_ids` for gateway endpoints such as S3.
