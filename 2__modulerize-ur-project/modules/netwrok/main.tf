#
# Network Infrastructure
#

# VPC
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.network_component[0].cidr_block
  tags = {
      Name = "${var.env_prefix}-${var.network_component[0].name}"
  }
}
#public-subnet-1
resource "aws_subnet" "myapp-public-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.network_component[1].cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-${var.network_component[1].name}"
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
 
#Igw
resource "aws_internet_gateway" "myapp-igw" {
	vpc_id = aws_vpc.myapp-vpc.id
    
    tags = {
     Name = "${var.env_prefix}-internet-gateway"
   }
}


# Associate subnet with Route Table
resource "aws_route_table_association" "associate-RT-subnet" {
  subnet_id      = aws_subnet.myapp-public-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}
