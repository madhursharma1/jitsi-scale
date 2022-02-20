output "alb-tg-arn" {
  value = aws_lb_target_group.alb-tg.arn
}

output "alb-security-group-id" {
  value = aws_security_group.alb-security-group.id
}