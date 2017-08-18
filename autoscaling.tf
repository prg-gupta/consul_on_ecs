resource "aws_autoscaling_group" "consul" {
  name_prefix = "${var.project}-${var.environment}-${var.component}-"
  max_size    = "${var.desired_count}"
  min_size    = "${var.desired_count}"

  desired_capacity = "${var.desired_count}"

  default_cooldown = 300

  launch_configuration = "${aws_launch_configuration.consul.name}"

  health_check_type = "EC2"

  force_delete = false

  vpc_zone_identifier = "${var.instance_subnets}"

  metrics_granularity = "1Minute"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  wait_for_capacity_timeout = "10m"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-${var.component}"
    propagate_at_launch = true
  }

  tag {
    key                 = "BILLING"
    value               = "${lookup(var.default_tags,"BILLING")}"
    propagate_at_launch = true
  }

  tag {
    key                 = "PROJECT"
    value               = "${lookup(var.default_tags,"PROJECT")}"
    propagate_at_launch = true
  }

  tag {
    key                 = "ENVIRONMENT"
    value               = "${lookup(var.default_tags,"ENVIRONMENT")}"
    propagate_at_launch = true
  }

  tag {
    key                 = "COMPONENT"
    value               = "${lookup(var.default_tags,"COMPONENT")}"
    propagate_at_launch = true
  }

  tag {
    key                 = "CONSUL"
    value               = "${lookup(var.default_tags,"CONSUL")}"
    propagate_at_launch = true
  }

  tag {
    key                 = "MANAGED_BY"
    value               = "${lookup(var.default_tags,"MANAGED_BY")}"
    propagate_at_launch = true
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.tpl")}"

  vars {
    ecs_cluster_name = "${aws_ecs_cluster.consul.name}"
    region = "${var.region}"
    nrpe_server_enabled           = "${lookup(var.nrpe_server, "enabled")}"
    nrpe_server_image             = "${lookup(var.nrpe_server, "image")}"
    nrpe_server_memoryReservation = "${lookup(var.nrpe_server, "memoryReservation")}"
  }
}

resource "aws_launch_configuration" "consul" {
  name_prefix                 = "${var.project}-${var.environment}-${var.component}-"
  image_id                    = "${lookup(var.amis, var.region)}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${concat(list(aws_security_group.consul_ecs.id),var.security_groups)}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ecsInstanceProfile.id}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = false
  user_data                   = "${data.template_file.user_data.rendered}"
  enable_monitoring           = true
  ebs_optimized               = false

  root_block_device {
    volume_size           = "${lookup(var.root_block_device, "volume_size")}"
    volume_type           = "${lookup(var.root_block_device, "volume_type")}"
    delete_on_termination = "${lookup(var.root_block_device, "delete_on_termination")}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
