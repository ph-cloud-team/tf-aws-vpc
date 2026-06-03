# Security

## Controls

- VPC CIDR allocation must come from AWS VPC IPAM.
- Subnets do not auto-assign public IPv4 addresses.
- Required tags are applied to supported network resources.
- NAT Gateway egress is explicit and monitored.
- Private route tables are separated per AZ for future route customization.

## Lab Egress Position

For the current lab, one NAT Gateway is used so private EKS workloads can reach external services such as GitLab SaaS when required by GitOps workflows. Production designs should decide between NAT, egress proxy, private Git hosting, VPC peering, VPN, or Direct Connect depending on the target operating model.
