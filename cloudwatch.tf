resource "aws_cloudwatch_log_group" "consul" {
  name              = "/${var.project}/${var.environment}/${var.component}/"
  retention_in_days = 7
  tags              = "${var.default_tags}"
}
