resource "aws_alb" "consul" {
  name            = "${var.project}-${var.environment}-${var.component}-ecs-alb"
  internal        = "${var.internal}"
  security_groups = ["${aws_security_group.consul_alb.id}"]
  subnets         = ["${var.alb_subnets}"]

  enable_deletion_protection = false

  tags = "${merge(var.default_tags, map("Name", "${var.project}-${var.environment}-${var.component}-ecs-alb"))}"
}

resource "aws_alb_listener" "consul_alb_80" {
  load_balancer_arn = "${aws_alb.consul.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.consul.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "consul" {
  name                 = "${var.project}-${var.environment}-${var.component}-alb-tg"
  port                 = 8500
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = 30

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 10
    interval            = 5
    timeout             = 4
    matcher             = "200-499"
  }

  tags = "${var.default_tags}"

  depends_on = [
    "aws_alb.consul",
  ]
}
