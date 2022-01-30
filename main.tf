#https://registry.terraform.io/providers/hashicorp/aws/latest/docs
locals {
  asg_name       = "${var.environment}-${var.asg_name}"
  lt_name        = "${var.environment}-${var.asg_name}-lt"
  module_version = trimspace(chomp(file("./version")))
  last_update    = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  tags = merge(var.tags, {
    environment    = "${var.environment}",
    application    = "${var.application}",
    module_name    = "terraform-aws-ec2-autoscaling-group",
    module_version = "${local.module_version}",
    last_update    = "${local.last_update}"
  })
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name}*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  owners = ["${data.aws_caller_identity.current.account_id}"]
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "this" {
  key_name   = "${var.environment}-ec2-keypair"
  public_key = var.ec2_key_pair
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "this" {
  name                   = local.lt_name
  image_id               = data.aws_ami.this.id
  instance_type          = var.environment == "prd" ? var.ec2_instance_type : "t2.micro"
  key_name               = "${var.environment}-ec2-keypair"
  vpc_security_group_ids = var.lt_security_group_list
  user_data              = "IyEvYmluL2Jhc2gKeXVtIHVwZGF0ZSAteQpzdWRvIHN5c3RlbWN0bCBlbmFibGUgYXdzbG9nc2Quc2VydmljZQpzdWRvIHN5c3RlbWN0bCBzdG9wIGF3c2xvZ3NkCnN1ZG8gc3lzdGVtY3RsIHN0YXJ0IGF3c2xvZ3NkCnN1ZG8gc3lzdGVtY3RsIHN0YXR1cyBhd3Nsb2dzZAo="
  iam_instance_profile {
    name = "${var.environment}-EC2InstanceRole"
  }

  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }

  credit_specification {
    cpu_credits = "standard"
  }

  block_device_mappings {
    ebs {
      encrypted   = true
      volume_type = "standard"
    }
  }

  ebs_optimized = true
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  update_default_version = true
  lifecycle {
    create_before_destroy = true
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "this" {
  name                      = local.asg_name
  max_size                  = var.environment == "prd" ? 6 : var.asg_max_size
  min_size                  = var.environment == "prd" ? 2 : var.asg_min_size
  desired_capacity          = var.environment == "prd" ? 3 : var.asg_desired_capacity
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = "ELB"
  termination_policies      = ["OldestLaunchConfiguration", "ClosestToNextInstanceHour"]
  vpc_zone_identifier       = var.asg_subnets_list

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tags = [
    {
      "key"                 = "Name"
      "value"               = "${var.asg_name}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "environment"
      "value"               = "${var.environment}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "application"
      "value"               = "${var.application}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "module_name"
      "value"               = "terraform-aws-ec2-autoscaling-group"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "module_version"
      "value"               = "${local.module_version}"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "last_update"
      "value"               = "${local.last_update}"
      "propagate_at_launch" = false
    }
  ]
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment
resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  alb_target_group_arn   = var.lb_tg_arn
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.this.name
}
