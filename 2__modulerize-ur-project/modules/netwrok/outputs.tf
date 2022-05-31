output "vpc" {
  value = aws_vpc.myapp-vpc
}

output "public_subnet_1" {
  value = aws_subnet.myapp-public-subnet-1  # this will grap all the resources created and u can later query any of them like id or name for ex.
}

