#!/bin/bash
yum update -y
sudo systemctl enable awslogsd.service
sudo systemctl stop awslogsd
sudo systemctl start awslogsd
sudo systemctl status awslogsd
