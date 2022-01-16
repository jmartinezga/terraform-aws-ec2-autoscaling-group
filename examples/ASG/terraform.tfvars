# Common variables
region      = "eu-west-1"
application = "helloworld"
environment = "dev"

# Module variables
asg_name               = "app-asg"
ami_name               = "golden-ami"
asg_subnets_list       = ["subnet-0d61bb60d3f0f837a", "subnet-00e68e973888cd82c"]
lc_security_group_list = ["sg-04c6d4ea8c5822f44"]
lb_tg_arn              = "arn:aws:elasticloadbalancing:eu-west-1:365101756910:targetgroup/dev-app-lb-tg/132cec38da9e8f6c"
