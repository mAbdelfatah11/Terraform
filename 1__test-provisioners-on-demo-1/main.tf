
# Demo: create AWS infrastructure for deployiny a dockerized app.    
#
# author: Mahmoud Abdelfatah / DevOps engineer - WideBot
# 

provider "aws" {
  region = "us-west-2"
}

#
# Variables
#
variable cidr_blocks {
  description = "list of objects includes cidr-blocks for vpc and subnets "
  type = list(object({
    name = string
    cidr_block = string   #pass environemnt as a tag value for each resource.

  }))
}
variable env_prefix {}
variable avail_zone {}
variable my_ip {}
variable public-key-location {}
variable instance_type {}



#
# Infrastructure
#
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  tags = {
      Name = "${var.env_prefix}-vpc"
  }
}
#public-subnet-1
resource "aws_subnet" "myapp-public-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.cidr_blocks[1].cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-public-subnet-1"
  } 
}
#Igw
resource "aws_internet_gateway" "myapp-igw" {
	vpc_id = aws_vpc.myapp-vpc.id
    
    tags = {
     Name = "${var.env_prefix}-internet-gateway"
   }
}
#RT
resource "aws_route_table" "myapp-route-table" {
   vpc_id = aws_vpc.myapp-vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.myapp-igw.id
   }
   # default route, mapping VPC CIDR block to "local", created implicitly and cannot be specified explicitly.
   tags = {
     Name = "${var.env_prefix}-route-table"
   }
 }
# Associate subnet with Route Table
resource "aws_route_table_association" "associate-RT-subnet" {
  subnet_id      = aws_subnet.myapp-public-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}



#
# Servers
#

#ami
data "aws_ami" "amazon-linux-image" {
  most_recent = true      # grab the first one that owned by amazon after applying the following filters
  owners      = ["amazon"]  #specify owner account-id or owner alias like "amazon" or "self" if this image owned by amazon or my account.

  filter {
    name   = "name" #match by name
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ami_id" {
  value = data.aws_ami.amazon-linux-image.id
}

#SecGroup
resource "aws_security_group" "myapp-sg" {
  name   = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port   = 22    #note: if you specified from-to values to be = 0 to 1000  for example, then you implicitly allow 1000 open ports
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] #src
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0 #all
    to_port         = 0
    protocol        = "-1"  #all
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []  # allow accessing all vpc endpoints
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

#keyPair
resource "aws_key_pair" "ssh-key" {
  key_name   = "server_key"
  public_key = file(var.public-key-location)   #create keypair locally using >$ ssh-keygen -t rsa -f key-name , then refer to pub key location instead of hardcoding key.
}

# EC2-instance-1
resource "aws_instance" "myapp-server" {
  ami                         = data.aws_ami.amazon-linux-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.myapp-public-subnet-1.id
  availability_zone			      = var.avail_zone
  vpc_security_group_ids      = [aws_security_group.myapp-sg.id]  
  associate_public_ip_address = true
  key_name                    = "server_key"    #or: aws_key_pair.ssh-key.key_name

  #user_data = file("entry-script.sh")

#
# Provisioners - "are not recommended by terraform"
#
# it is important to note that provisioners are more provisioned function for executing remote scripts but it is not recommended.
# helpful function rather than "user_data" 'cause user-data only "passes" the commands to the remote server after creation, so u are not aware if this commands got executed or not, terraform does not let u know what happened, it just tells u that resource created succeffuly, but,
# provisioners help u know more about script, it is like when u ssh to a remote server to execute commands so it is more provisioned tha user-data
# if the provisioner function is not executed successfully, whole resource will marked as fail after issuing > terraform apply, so it let u know!!

#why prov. is not recommended?
# it breaks the base idea of terraform "current-desired state comparison", if u executed the script for the first time in the server, terraform did not actually know what you had done there, becaue you copied the script from local to the remote then executed it there, then for the next time, TF can not compare current state in the server with the desired state, it does not actually know what happened there.
# for user-data, terraform "hashes" and "pass" it to the server, so next time it will compare the current hash with the new hash, if the new hash id differ from current one, then TF will execute the user-data again to apply the changes.

# in general, for the best practices, u can use terraform for provisioning infrastructure, and use Ansible tool for configuration managment to remote servers like issuing commands and installing utilities and others, config. management tools are more efficient for config. purpose.
# also  use can use provioner "local-exec" function for local provisioning or something like that.
# also as most as possible, try to use user-data over provisioner.

  connection {
        type = "ssh"
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.private_key_location)
    }

  provisioner "file" {
        source = "entry-script.sh"
        destination = "/home/ec2-user/entry-script-on-ec2.sh"
    }

  provisioner "remote-exec" {
        script = file("entry-script.sh")
    }

  provisioner "local-exec" {
        command = "echo ${self.public_ip} > output.txt"
    }
  tags = {
    Name = "${var.env_prefix}-server"
  }


}
output "server-ip" {
    value = aws_instance.myapp-server.public_ip
}

/*

# EC2-instance-2

resource "aws_instance" "myapp-server-two" {
  ami                         = data.aws_ami.amazon-linux-image.id
  instance_type               = var.instance_type
  key_name                    = "myapp-key"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.myapp-sg.id]
  availability_zone			      = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-server-two"
  }

  user_data = <<EOF
                 #!/bin/bash
                 apt-get update && apt-get install -y docker-ce
                 systemctl start docker
                 usermod -aG docker ec2-user
                 docker run -p 8080:8080 nginx
              EOF
}
*/
