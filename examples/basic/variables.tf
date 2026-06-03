variable "ipv4_ipam_pool_id" {
  description = "Existing IPAM pool ID used for VPC allocation."
  type        = string
  default     = "ipam-pool-0123456789abcdef0"
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN used by encrypted module examples."
  type        = string
}
