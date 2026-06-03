############################################
# Local values for tf-aws-vpc
############################################

locals {
  module_name = "tf-aws-vpc"

  common_tags = merge(
    {
      ManagedBy = "terraform"
      Module    = local.module_name
    },
    var.tags
  )

  public_subnet_map = {
    for index, az in var.availability_zones : az => {
      availability_zone = az
      cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, var.public_subnet_newbits, index)
      name              = "${var.name}-public-${az}"
    }
  }

  private_subnet_map = {
    for index, az in var.availability_zones : az => {
      availability_zone = az
      cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, var.private_subnet_newbits, length(var.availability_zones) + index)
      name              = "${var.name}-private-${az}"
    }
  }
}
