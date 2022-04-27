vpc_cidr             = "10.0.0.0/16"
env                  = "dev"
public_subnet_cidrs  = ["10.0.1.0/24","10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24","10.0.22.0/24"]

# Security Group
allow_ports = ["80", "443", "8080", "22"]
sg_id       = ["ecs_ha_sg"]

# ECR repo
image_names = ["ecr_ha_cluster"]

# ECS Cluster
ecs_cluster_name = "ecs_ha_cluster"

# ALB
alb_name = "ecs_alb_ha"

#VPC ID
vpc_id = "vpc_id"

tag_name = "Ahmad"

owner_name = "Ahmad"
