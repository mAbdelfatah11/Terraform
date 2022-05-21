#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker 
sudo usermod -aG docker ec2-user
docker pull mabdelfatah/voting-app-py:v0.0.1
docker run -ti -v /tmp:/tmp -dp 8080:80 mabdelfatah/voting-app-py:v0.0.1
