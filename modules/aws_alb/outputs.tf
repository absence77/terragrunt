output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "alb_name" {
  value = aws_alb.alb.name
}

output "target_group90_arn" {
  value = aws_lb_target_group.target_group90.arn
}