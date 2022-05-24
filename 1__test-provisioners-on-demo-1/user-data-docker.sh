#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl start docker.service
#add ec2-user to docker group
sudo usermod -aG docker ec2-user    
docker pull mabdelfatah/voting-app-py:v0.0.1
docker run -ti -v /tmp:/tmp -dp 8080:80 mabdelfatah/voting-app-py:v0.0.1
#sudo docker run -dp -v /tmp:/tmp 8080:8080 nginx


