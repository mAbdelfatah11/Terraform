
#
# Servers
#

#ami
data "aws_ami" "amazon-linux-image" {
  most_recent = true      # grab the first one that owned by amazon after applying the following filters
  owners      = ["amazon"]  #specify owner account-id or owner alias like "amazon" or "self" if this image owned by amazon or my account.

  filter {
    name   = "name" #match by name
    values = [var.image_name_filter] # 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



#SecGroup
resource "aws_security_group" "myapp-sg" {
  name   = "myapp-sg"
  vpc_id = var.vpc_id

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
  key_name   = var.keyName
  public_key = file(var.public_key_location)   #create keypair locally using >$ ssh-keygen -t rsa -f key-name , then refer to pub key location instead of hardcoding key.
}

# EC2-instance-1
resource "aws_instance" "myapp-server" {
  ami                         = data.aws_ami.amazon-linux-image.id
  instance_type               = var.instance_type
  # you can not directly refer to subnet id from another module, instead call the variable directly in the root main.tf file as an output resource from another module
  subnet_id                   = var.public_subnet_id
  availability_zone			  = var.avail_zone
  vpc_security_group_ids      = [aws_security_group.myapp-sg.id]  
  associate_public_ip_address = true
  key_name                    = var.keyName   #or: aws_key_pair.ssh-key.key_name

  user_data = file(var.entry_script_location)
  user_data_replace_on_change = true
  
  tags = {
    Name = "${var.env_prefix}-server"
  }


}
