# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "${var.name_prefix}-vpc-flow-logs"
  retention_in_days = var.cloud_watch_retention
}
