resource "aws_autoscaling_notification" "consul_asg_notification" {
  group_names = [
    "${aws_autoscaling_group.consul.name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "${aws_sns_topic.consul_asg_sns.arn}"
}

resource "aws_sns_topic" "consul_asg_sns" {
  name = "${var.project}-${var.environment}-${var.component}-notifications"
}

resource "aws_sns_topic_subscription" "asg_sns_subscription" {
  count     = "${var.icinga}"
  topic_arn = "${aws_sns_topic.consul_asg_sns.arn}"
  protocol  = "sqs"
  endpoint  = "${var.asg_montior_sqs_endpoint}"
}
