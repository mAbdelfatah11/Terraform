# as all the configs was modularized, u can not make output directly in the root output file here from modules
# u should extract output first in the module output file, then refer to the outputs in the root output file 

output "vpc_id" {
  value = module.network_infra.vpc.id  # grap only the id object from whole output in the module output resource "vpc"
}

output "server_Public_ip" {
    value = module.webserver.server_Public_ip   # grap public ip of the ec2 instance
}
