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
ec2_key_pair           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkSgRJCgVNDxg3EOZfM6kiIb+nUwM4GfNtBjuDyEowgm8et3xt2a/e7eAVtv/ZHJuFO9XZQEqVT/LZ2vTAiBOLTlsfS/7ERYY0H8yzJVrsxSEiMprZqO+Pk3gvt8xenkZWXM0q2NtCR+ZfLO91UuW9V/PAvZqgBTLkvIEr53l7vWvtcTlrz0Q/5b+yLHIfYjueLZpHOP8fzCpV6MwKZ8A9U3S+i4jl658zIZBjj7j+Tct9H5Z8t6fZ0Z9yPSM2dwVxNWrFre07/hmaevX87meJi8bapVt09k6qGW8UQAsWvGBSBtX5TtfQOUXCpfRbHDciOnj7GC5d780RBhSp9N1Y3On7djYTCLdo2te5qLVRmOmh/eMzo3mnhq2uveUtGglnf8DQ8ENX2tSsMOpn1niY33hZHth+ZJgle0cNILCjBOPs66a+a7tqncZlWjOsXQer95tcqUnhQLKn+zMPdbCkUHdNfm/dsvKqFqOj6v7jvXMqFkzBSnmoTyaa0TzELBc= jordi@desktop"
