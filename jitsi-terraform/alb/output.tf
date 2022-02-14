output "alb-tb-arn" {
  value = aws_lb_target_group.alb-tb.arn
}

output "alb-security-group-id" {
  value = aws_security_group.alb-security-group.id
}