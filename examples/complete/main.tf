module "tf_aws_vpc" {
  source = "../../"

  name                 = "dev-platform-vpc"
  ipv4_ipam_pool_id    = var.ipv4_ipam_pool_id
  ipv4_netmask_length  = 20
  availability_zones   = ["us-east-1a", "us-east-1b"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  flow_log_kms_key_arn = var.kms_key_arn

  tags = {
    Name               = "dev-platform-vpc"
    Environment        = "dev"
    Owner              = "platform-team"
    CostCenter         = "shared-services"
    Application        = "eks-platform"
    DataClassification = "internal"
  }
}
