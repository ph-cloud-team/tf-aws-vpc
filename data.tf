############################################
# Data sources for tf-aws-vpc
############################################

data "aws_iam_policy_document" "flow_logs_assume_role" {
  statement {
    sid     = "AllowVpcFlowLogsServiceAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "flow_logs" {
  statement {
    sid = "AllowVpcFlowLogsWrite"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.vpc_flow_logs[0].arn,
      format("%s:*", aws_cloudwatch_log_group.vpc_flow_logs[0].arn)
    ]
  }
}
