variable "region" {}

variable "project" {
  description = "Project Key. Will be used to create resource prefixes."
}

variable "environment" {
  description = "Preoject environment. Will be used to create resource prefixes."
}

variable "component" {
  description = "Preoject component. Will be used to create resource prefixes."
}

variable "internal" {
  default = true
}

variable "vpc_id" {}

variable "alb_subnets" {
  type = "list"
}

variable "instance_subnets" {
  type = "list"
}

variable "default_tags" {
  type = "map"
}

variable "amis" {
  type = "map"
}

variable "allowed_networks" {
  type    = "list"
  default = ["10.0.0.0/8"]
}

variable "desired_count" {}
variable "deployment_maximum_percent" {}
variable "deployment_minimum_healthy_percent" {}

variable "root_block_device" {
  type = "map"
}

variable "instance_type" {}

variable "security_groups" {
  type = "list"
}

variable "key_name" {}

variable "images" {
  type = "map"
}

variable "icinga" {}

variable "asg_montior_sqs_endpoint" {
  default = "dummy-sqs"
}

variable "nrpe_server" {
  type = "map"
}
