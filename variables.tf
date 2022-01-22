#https://www.terraform.io/language/values/variables
###############################################################################
# Required variables
###############################################################################
variable "asg_name" {
  description = "(Required) Autoscaling Group name."
  type        = string

  validation {
    condition     = length(var.asg_name) > 0
    error_message = "Load Balancer name is required."
  }
}

variable "asg_subnets_list" {
  description = "(Required) Load Balancer subnets id list."
  type        = list(string)

  validation {
    condition     = length(var.asg_subnets_list) > 0
    error_message = "ASG Subnets list is required."
  }
}

variable "ami_name" {
  description = "(Required) AMI Name."
  type        = string

  validation {
    condition     = length(var.ami_name) > 0
    error_message = "AMI name is required."
  }
}

variable "lc_security_group_list" {
  description = "(Required) Launch Configuraion Security Group id list."
  type        = list(string)

  validation {
    condition     = length(var.lc_security_group_list) > 0
    error_message = "Launch Configuraion Security Group id list is required."
  }
}
variable "lb_tg_arn" {
  description = "(Required) Load Balancer target group arn."
  type        = string

  validation {
    condition     = length(var.lb_tg_arn) > 0
    error_message = "Load Balancer target group arn is required."
  }
}

variable "ec2_key_pair" {
  description = "(Required) EC2 key pair."
  type        = string

  validation {
    condition     = can(regex("^ssh-rsa.*", var.ec2_key_pair))
    error_message = "EC2 key pair is required."
  }
}

###############################################################################
# Optional variables
###############################################################################
variable "asg_max_size" {
  description = "(Optional) Autoscaling Group max size."
  type        = number
  default     = 1

  validation {
    condition     = var.asg_max_size >= 1 || var.asg_max_size <= 3
    error_message = "Autoscaling Group max size should be a number between 1 and 3."
  }
}
variable "asg_min_size" {
  description = "(Optional) Autoscaling Group max size."
  type        = number
  default     = 1

  validation {
    condition     = var.asg_min_size >= 1 || var.asg_min_size <= 3
    error_message = "Autoscaling Group min size should be a number between 1 and 3."
  }
}

variable "asg_desired_capacity" {
  description = "(Optional) Autoscaling Group max size."
  type        = number
  default     = 1

  validation {
    condition     = var.asg_desired_capacity >= 1 || var.asg_desired_capacity <= 3
    error_message = "Autoscaling Group desired capacity should be a number between 1 and 3."
  }
}

variable "ec2_instance_type" {
  description = "(Optiona) EC2 Instance type."
  type        = string
  default     = "m4.large"

  validation {
    condition     = can(regex("m[4|5][d]{0,1}[.][a-zA-Z]*", var.ec2_instance_type))
    error_message = "EC2 Instance type must be m4[d].* or m5[d].* ."
  }
}

variable "ec2_instance_root_volum_size" {
  description = "(Optiona) EC2 root volume size."
  type        = number
  default     = 8

  validation {
    condition     = can(regex("[0-9]{1,3}", var.ec2_instance_root_volum_size))
    error_message = "EC2 Instance root volum size should be between [8 - 999]."
  }
}
