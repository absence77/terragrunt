####### CREATE CLUSTER #######
resource "aws_ecs_cluster" "ecs_ha_cluster" {
  name = "ecs_ha_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}

####### CREATE IAM ROLE FOR TASK DEFINITION ###########

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-ha-role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-ha-role-task"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_s3" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

############# CREATE TASK DEFINITION ##################


resource "aws_ecs_task_definition" "test" {
  family                   = "test"
  task_role_arn            = "${aws_iam_role.ecs_task_role.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "iis",
    "image": "${var.image_name}:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80

      },
      {
        "containerPort": 90,
        "hostPort": 90
      }
    ]    
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}

########### CREATE SERVICE ###########

resource "aws_ecs_service" "ecs_ha1" {

  name            = "ecs_ha1"
  cluster         = aws_ecs_cluster.ecs_ha_cluster.id
  task_definition = aws_ecs_task_definition.test.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  

  network_configuration {
    security_groups = [var.security_group_id]
    subnets         = var.subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "iis"
    container_port   = 80
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}

resource "aws_ecs_service" "ecs_ha2" {

  name            = "ecs_ha2"
  cluster         = aws_ecs_cluster.ecs_ha_cluster.id
  task_definition = aws_ecs_task_definition.test.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  

  network_configuration {
    security_groups = [var.security_group_id]
    subnets         = var.subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group90_arn
    container_name   = "iis"
    container_port   = 90
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}