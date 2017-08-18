data "aws_caller_identity" "current" {}

data "aws_subnet" "private_subnets" {
  count = "${length(var.instance_subnets)}"
  id    = "${element(var.instance_subnets, count.index)}"
}
