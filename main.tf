#
# Provider
#

provider "aws" {}


#
# Variables 
#

variable cidr_blocks {
    description = "cidr blocks and name tags for vpc and subnets"
    type = list(object({
        cidr_block = string
        name = string
    }))
}

#
# Environemnt variables
#

variable "avail_zone" {}

#
# Resources
#
resource "aws_vpc" "cluster-vpc" {
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
        Name = var.cidr_blocks[0].name
    }
}

resource "aws_subnet" "cluster-subnet-1" {
    vpc_id = aws_vpc.cluster-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    #availability_zone = var.avail_zone
    tags = {
        Name = var.cidr_blocks[1].name
    }
}

data "aws_vpc" "Existing-vpc" {
    default = true
  
}

resource "aws_subnet" "cluster-subnet-2" {
    vpc_id = data.aws_vpc.Existing-vpc.id
    cidr_block = var.cidr_blocks[2].cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "cluster-subnet-2"
    }
}
# 
# Outputs
#
output "clutser-vpc" {
    value = aws_vpc.cluster-vpc.id
}

output "cluster-subnet-1_id" {
    value = aws_subnet.cluster-subnet-1.id
}

output "cluster-subnet-2_id" {
    value = aws_subnet.cluster-subnet-2.id
}