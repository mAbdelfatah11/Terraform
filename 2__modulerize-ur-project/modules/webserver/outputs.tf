output "server_Public_ip" {
    value = aws_instance.myapp-server.public_ip
  
}