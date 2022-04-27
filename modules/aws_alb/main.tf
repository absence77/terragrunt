
###########  LOAD BALANCER ###########

resource "aws_alb" "alb" {  
  name            = "ecs-alb"  
  subnets         = var.subnets
  security_groups = ["${var.security_group_id}"]
  internal        = false  

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
  
}

########### LISTENERS #################

resource "aws_alb_listener" "alb_listener80" {  
  load_balancer_arn = aws_alb.alb.arn 
  port              = "80"  
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    type             = "forward"  
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}


############ LISTENERS RULES ##############3

resource "aws_alb_listener_rule" "listener_rule_api" {
  depends_on   = [aws_lb_target_group.target_group]  
  listener_arn = aws_alb_listener.alb_listener80.arn

  action {    
    type             = "forward"    
    target_group_arn = "${aws_lb_target_group.target_group.id}"  
  }   
  condition {    
    path_pattern {
      values = ["/api"] 
  }
}

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}

resource "aws_alb_listener_rule" "listener_rule_service" {
  depends_on   = [aws_lb_target_group.target_group]  
  listener_arn = aws_alb_listener.alb_listener80.arn

  action {    
    type             = "forward"    
    target_group_arn = "${aws_lb_target_group.target_group90.id}"  
  }   

  condition {
   source_ip {
     values = ["${var.eip}/32"]
   }
}
  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}


############## TARGET GROUP ###############

resource "aws_lb_target_group" "target_group" {
  name        = "service80"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}


resource "aws_lb_target_group" "target_group90" {
  name        = "service90"
  port        = 90
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path      = "/service/"
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}