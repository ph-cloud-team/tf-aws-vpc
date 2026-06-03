############################################
# Input variables for tf-aws-vpc
############################################

variable "name" {
  description = "Name prefix for the VPC and network resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "name must be lowercase DNS-safe text between 3 and 63 characters."
  }
}

variable "ipv4_ipam_pool_id" {
  description = "IPAM pool ID used to allocate the VPC IPv4 CIDR."
  type        = string

  validation {
    condition     = can(regex("^ipam-pool-[a-z0-9]+$", var.ipv4_ipam_pool_id))
    error_message = "ipv4_ipam_pool_id must look like ipam-pool-xxxxxxxx."
  }
}

variable "ipv4_netmask_length" {
  description = "Netmask length for the VPC CIDR allocation from IPAM."
  type        = number
  default     = 20

  validation {
    condition     = var.ipv4_netmask_length >= 16 && var.ipv4_netmask_length <= 24
    error_message = "ipv4_netmask_length must be between 16 and 24."
  }
}

variable "availability_zones" {
  description = "Availability zones where public and private subnets are created."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "availability_zones must include at least two AZs."
  }
}

variable "public_subnet_newbits" {
  description = "Additional subnet bits for public subnet CIDRs derived from the VPC CIDR."
  type        = number
  default     = 4
}

variable "private_subnet_newbits" {
  description = "Additional subnet bits for private subnet CIDRs derived from the VPC CIDR."
  type        = number
  default     = 4
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "Allowed tenancy of instances launched into the VPC."
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "instance_tenancy must be default or dedicated."
  }
}

variable "enable_internet_gateway" {
  description = "Create and attach an internet gateway for public subnets."
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway egress for private subnets."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for the VPC. This is cost-conscious for lab/dev; production may use one per AZ."
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Whether public subnets assign public IPv4 addresses on launch."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network auditability."
  type        = bool
  default     = true
}

variable "flow_log_kms_key_arn" {
  description = "Customer-managed KMS key ARN used to encrypt the VPC Flow Logs CloudWatch log group."
  type        = string

  validation {
    condition     = can(regex(format("^%s:aws[a-zA-Z-]*:kms:[a-z0-9-]+:[0-9]{12}:key/.+", "arn"), var.flow_log_kms_key_arn))
    error_message = "flow_log_kms_key_arn must be a valid KMS key ARN."
  }
}

variable "flow_log_cloudwatch_log_group_name" {
  description = "Optional CloudWatch log group name for VPC Flow Logs."
  type        = string
  default     = null
}

variable "flow_log_retention_in_days" {
  description = "Retention in days for VPC Flow Logs."
  type        = number
  default     = 365

  validation {
    condition     = var.flow_log_retention_in_days >= 90
    error_message = "flow_log_retention_in_days must be at least 90 days."
  }
}

variable "flow_log_traffic_type" {
  description = "Traffic type captured by VPC Flow Logs."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_log_traffic_type)
    error_message = "flow_log_traffic_type must be ACCEPT, REJECT, or ALL."
  }
}

variable "flow_log_permissions_boundary_arn" {
  description = "Optional permissions boundary ARN for the VPC Flow Logs IAM role."
  type        = string
  default     = null

  validation {
    condition     = var.flow_log_permissions_boundary_arn == null || can(regex(format("^%s:aws[a-zA-Z-]*:iam::[0-9]{12}:policy/.+", "arn"), var.flow_log_permissions_boundary_arn))
    error_message = "flow_log_permissions_boundary_arn must be null or a valid IAM policy ARN."
  }
}

variable "nat_gateway_alarm_actions" {
  description = "Alarm action ARNs for NAT Gateway error port allocation alarms."
  type        = list(string)
  default     = []
}

variable "nat_gateway_ok_actions" {
  description = "OK action ARNs for NAT Gateway error port allocation alarms."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Required enterprise tags applied to supported resources."
  type        = map(string)

  validation {
    condition = alltrue([
      for key in ["Name", "Environment", "Owner", "CostCenter", "Application", "DataClassification"] :
      contains(keys(var.tags), key) && trimspace(var.tags[key]) != ""
    ])
    error_message = "tags must include non-empty Name, Environment, Owner, CostCenter, Application, and DataClassification values."
  }
}
