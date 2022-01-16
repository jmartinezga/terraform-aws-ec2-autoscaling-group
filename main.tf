#https://registry.terraform.io/providers/hashicorp/aws/latest/docs
locals {
  asg_name       = "${var.environment}-${var.asg_name}"
  lc_name        = "${var.environment}-${var.asg_name}-lc"
  tf_version     = trimspace(chomp(file("./tf_version")))
  module_version = trimspace(chomp(file("./version")))
  last_update    = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "app" {
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
  public_key = file("./${var.environment}-ec2-keypair.pub")
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration
resource "aws_launch_configuration" "this" {
  name                 = local.lc_name
  image_id             = data.aws_ami.app.id
  instance_type        = var.environment == "prd" ? var.ec2_instance_type : "t2.micro"
  iam_instance_profile = "${var.environment}-EC2InstanceRole"
  key_name             = "${var.environment}-ec2-keypair"
  security_groups      = var.lc_security_group_list
  user_data            = file("./userdata.sh")

  root_block_device {
    encrypted   = true
    volume_size = var.ec2_instance_root_volum_size
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  lifecycle {
    create_before_destroy = true
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "this" {
  name                      = local.asg_name
  max_size                  = 0
  min_size                  = 0
  desired_capacity          = 0
  health_check_grace_period = 300
  health_check_type         = "ELB"
  termination_policies      = ["OldestLaunchConfiguration", "ClosestToNextInstanceHour"]
  launch_configuration      = aws_launch_configuration.this.name
  vpc_zone_identifier       = var.asg_subnets_list

  tags = [
    {
      "key"                 = "Name"
      "value"               = "${var.asg_name}"
      "propagate_at_launch" = false
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
      "key"                 = "terraform"
      "value"               = "${local.tf_version}"
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
