output "launch_template_arn" {
  description = "Amazon Resource Name (ARN) of the launch template."
  value       = aws_launch_template.main[0].arn
}

output "launch_template_id" {
  description = "The ID of the launch template."
  value       = aws_launch_template.main[0].id
}
