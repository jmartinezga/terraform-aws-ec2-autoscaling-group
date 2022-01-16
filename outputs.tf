#https://www.terraform.io/language/values/outputs
output "asg_id" {
  description = "Autoscaling Group id."
  value       = aws_autoscaling_group.this.id
}

output "asg_arn" {
  description = "Autoscaling Group arn."
  value       = aws_autoscaling_group.this.arn
}
