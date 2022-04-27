variable "region" {
  default = "us-east-2" # Ohio

}

# VPC variables
variable "vpc_cidr" {}

variable "sg_id" {}

variable "env" {}

variable "public_subnet_cidrs" {
  type = list(any)
}

variable "private_subnet_cidrs" {
  type = list(any)
}

# Security Group
variable "allow_ports" {
  type = list(any)
}

# ECR
variable "image_names" {
  type = list(string)
}

# ECS 
variable "ecs_cluster_name" {}

#ALB
variable "alb_name" {}

#VPC ID
variable "vpc_id" {}


variable "tag_name" {}

variable "owner_name" {} 
