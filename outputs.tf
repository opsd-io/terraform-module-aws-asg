output "arn" {
  description = "Amazon Resource Name (ARN) of the Auto Scaling Group."
  value       = aws_autoscaling_group.main.arn
}

output "id" {
  description = "The ID of the Auto Scaling Group."
  value       = aws_autoscaling_group.main.id
}
