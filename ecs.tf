resource "aws_ecs_cluster" "consul" {
  name = "${var.project}-${var.environment}-${var.component}"
}

resource "aws_ecs_service" "consul" {
  name            = "${var.component}"
  cluster         = "${aws_ecs_cluster.consul.id}"
  task_definition = "${aws_ecs_task_definition.consul.arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${aws_iam_role.consul_service_role.arn}"

  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"
  deployment_maximum_percent         = "${var.deployment_maximum_percent}"

  depends_on = [
    "aws_iam_role_policy.consul_service_role_policy",
    "aws_alb_listener.consul_alb_80",
  ]

  placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  placement_constraints {
    type = "distinctInstance"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.consul.arn}"
    container_name   = "${var.component}"
    container_port   = 8500
  }
}

resource "aws_ecs_task_definition" "consul" {
  family        = "${var.component}"
  task_role_arn = "${aws_iam_role.ecsTaskRole.arn}"
  network_mode  = "host"

  volume {
    name      = "consul-data"
    host_path = "/consul/data"
  }

  container_definitions = <<EOF
[
  {
    "essential": true,
    "memoryReservation": 512,
    "name": "${var.component}",
    "image": "${lookup(var.images, "consul")}",
    "portMappings":[ 
      { 
          "hostPort":8300,
          "containerPort":8300,
          "protocol":"tcp"
      },
      { 
          "hostPort":8301,
          "containerPort":8301,
          "protocol":"tcp"
      },
      { 
          "hostPort":8301,
          "containerPort":8301,
          "protocol":"udp"
      },
      { 
          "hostPort":8302,
          "containerPort":8302,
          "protocol":"tcp"
      },
      { 
          "hostPort":8302,
          "containerPort":8302,
          "protocol":"udp"
      },
      { 
          "hostPort":8500,
          "containerPort":8500,
          "protocol":"tcp"
      },
      { 
          "hostPort":8600,
          "containerPort":8600,
          "protocol":"tcp"
      },
      { 
          "hostPort":8600,
          "containerPort":8600,
          "protocol":"udp"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "consul-data",
        "containerPath": "/consul/data"
      }
    ],
    "environment":[ 
      { 
        "name":"CONSUL_BIND_INTERFACE",
        "value":"eth0"
      }
    ],
    "command":[ 
      "agent",
      "-server",
      "-retry-join-ec2-tag-key",
      "CONSUL",
      "-retry-join-ec2-tag-value",
      "${lookup(var.default_tags,"CONSUL")}",
      "-bootstrap-expect",
      "${var.desired_count}",
      "-retry-join-ec2-region",
      "${var.region}",
      "-client",
      "0.0.0.0",
      "-ui"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/${var.project}/${var.environment}/${var.component}/",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "consul"
      }
    }
  }
]
EOF
}
