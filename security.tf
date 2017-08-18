resource "aws_security_group" "consul_alb" {
  name_prefix = "${var.project}-${var.environment}-${var.component}-alb-"
  description = "${var.project} ${var.environment} ${var.component} private security group for consul alb."
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = "${merge(var.default_tags, map("Name","${var.project}-${var.environment}-${var.component}-alb"))}"
}

resource "aws_security_group_rule" "alb_to_instances" {
  type                     = "ingress"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.consul_alb.id}"
  security_group_id        = "${aws_security_group.consul_ecs.id}"
}

resource "aws_security_group_rule" "alb_80" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks = "${var.allowed_networks}"

  security_group_id = "${aws_security_group.consul_alb.id}"
}

resource "aws_security_group" "consul_ecs" {
  name_prefix = "${var.project}-${var.environment}-${var.component}-ecs-"
  description = "${var.project} ${var.environment} ${var.component} private security group for consul ecs cluster."
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = "${merge(var.default_tags, map("Name","${var.project}-${var.environment}-${var.component}-ecs"))}"
}

resource "aws_security_group_rule" "server_RPC" {
  type      = "ingress"
  from_port = 8300
  to_port   = 8300
  protocol  = "tcp"

  self              = true
  security_group_id = "${aws_security_group.consul_ecs.id}"
}

resource "aws_security_group_rule" "serf_LAN_tcp" {
  type      = "ingress"
  from_port = 8301
  to_port   = 8301
  protocol  = "tcp"

  self              = true
  security_group_id = "${aws_security_group.consul_ecs.id}"
}

resource "aws_security_group_rule" "serf_LAN_udp" {
  type      = "ingress"
  from_port = 8301
  to_port   = 8301
  protocol  = "udp"

  self              = true
  security_group_id = "${aws_security_group.consul_ecs.id}"
}

resource "aws_security_group_rule" "serf_WAN_tcp" {
  type      = "ingress"
  from_port = 8302
  to_port   = 8302
  protocol  = "tcp"

  self              = true
  security_group_id = "${aws_security_group.consul_ecs.id}"
}

resource "aws_security_group_rule" "serf_WAN_udp" {
  type      = "ingress"
  from_port = 8302
  to_port   = 8302
  protocol  = "udp"

  self              = true
  security_group_id = "${aws_security_group.consul_ecs.id}"
}

resource "aws_security_group_rule" "HTTP_API" {
  count     = "${length(var.instance_subnets)}"
  type      = "ingress"
  from_port = 8500
  to_port   = 8500
  protocol  = "tcp"

  cidr_blocks = ["${element(data.aws_subnet.private_subnets.*.cidr_block, count.index)}"]

  security_group_id = "${aws_security_group.consul_ecs.id}"
}

resource "aws_security_group_rule" "DNS_Interface_tcp" {
  count     = "${length(var.instance_subnets)}"
  type      = "ingress"
  from_port = 8600
  to_port   = 8600
  protocol  = "tcp"

  cidr_blocks = ["${element(data.aws_subnet.private_subnets.*.cidr_block, count.index)}"]

  security_group_id = "${aws_security_group.consul_ecs.id}"
}

resource "aws_security_group_rule" "DNS_Interface_udp" {
  count     = "${length(var.instance_subnets)}"
  type      = "ingress"
  from_port = 8600
  to_port   = 8600
  protocol  = "udp"

  cidr_blocks = ["${element(data.aws_subnet.private_subnets.*.cidr_block, count.index)}"]

  security_group_id = "${aws_security_group.consul_ecs.id}"
}
