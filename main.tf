############################################
# Main resources for tf-aws-vpc
############################################

resource "aws_vpc" "this" {
  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  instance_tenancy                 = var.instance_tenancy
  ipv4_ipam_pool_id                = var.ipv4_ipam_pool_id
  ipv4_netmask_length              = var.ipv4_netmask_length

  tags = merge(local.common_tags, {
    Name = var.name
  })
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-default-sg-restricted"
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = coalesce(var.flow_log_cloudwatch_log_group_name, "/aws/vpc/${var.name}/flow-logs")
  kms_key_id        = var.flow_log_kms_key_arn
  retention_in_days = var.flow_log_retention_in_days

  tags = merge(local.common_tags, {
    Name = "${var.name}-flow-logs"
  })
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name                 = "${var.name}-flow-logs-role"
  assume_role_policy   = data.aws_iam_policy_document.flow_logs_assume_role.json
  description          = "IAM role used by VPC Flow Logs for ${var.name}"
  permissions_boundary = var.flow_log_permissions_boundary_arn

  tags = merge(local.common_tags, {
    Name = "${var.name}-flow-logs-role"
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name   = "${var.name}-flow-logs-write"
  role   = aws_iam_role.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs.json
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = var.flow_log_traffic_type
  vpc_id          = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-flow-logs"
  })
}

resource "aws_internet_gateway" "this" {
  count = var.enable_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnet_map

  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = var.map_public_ip_on_launch
  vpc_id                  = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = each.value.name
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnet_map

  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = each.value.name
    Tier = "private"
  })
}

resource "aws_route_table" "public" {
  count = var.enable_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-public-rt"
    Tier = "public"
  })
}

resource "aws_route_table_association" "public" {
  for_each = var.enable_internet_gateway ? aws_subnet.public : {}

  route_table_id = aws_route_table.public[0].id
  subnet_id      = each.value.id
}

resource "aws_eip" "nat" {
  #checkov:skip=CKV2_AWS_19:NAT gateway requires a public EIP for controlled private subnet egress.
  for_each = var.enable_nat_gateway ? (
    var.single_nat_gateway ? { (var.availability_zones[0]) = aws_subnet.public[var.availability_zones[0]] } : aws_subnet.public
  ) : {}

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.name}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = aws_eip.nat

  allocation_id = each.value.id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(local.common_tags, {
    Name = "${var.name}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[var.availability_zones[0]].id : aws_nat_gateway.this[each.key].id
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-${each.key}-rt"
    Tier = "private"
  })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = each.value.id
}

resource "aws_cloudwatch_metric_alarm" "nat_gateway_error_port_allocation" {
  for_each = aws_nat_gateway.this

  alarm_actions       = var.nat_gateway_alarm_actions
  alarm_description   = "NAT Gateway ErrorPortAllocation alarm for ${each.value.tags.Name}"
  alarm_name          = "${each.value.tags.Name}-error-port-allocation"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorPortAllocation"
  namespace           = "AWS/NATGateway"
  ok_actions          = var.nat_gateway_ok_actions
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    NatGatewayId = each.value.id
  }

  tags = merge(local.common_tags, {
    Name = "${each.value.tags.Name}-error-port-allocation"
  })
}
