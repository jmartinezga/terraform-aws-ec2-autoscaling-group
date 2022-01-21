#https://www.terraform.io/language/values/outputs
output "id" {
  description = "Autoscaling Group id."
  value       = aws_autoscaling_group.this.id
}

output "arn" {
  description = "Autoscaling Group arn."
  value       = aws_autoscaling_group.this.arn
}

output "name" {
  description = "Autoscaling Group name."
  value       = local.asg_name
}
