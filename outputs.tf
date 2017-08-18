output "Consul ECS Cluster Name" {
  value = "${aws_ecs_cluster.consul.name}"
}

output "Consul ALB Endpoint" {
  value = "${aws_alb.consul.dns_name}"
}
