
#
# Demo: create AWS infrastructure for deployiny a dockerized app.    
# author: Mahmoud Abdelfatah / DevOps engineer - WideBot




module "network_infra" {
  source = "./modules/netwrok"
  network_component = var.network_component
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix

}

module "webserver" {
  source = "./modules/webserver"
  vpc_id = module.network_infra.vpc.id  #network_infra module output resource, u can refer to another module output resource only at the root main.tf here, u can not refer to any module output in .tfvars file or main.tf file for another module
  env_prefix = var.env_prefix
  my_ip = var.my_ip
  image_name_filter = var.image_name_filter
  public_key_location = var.public_key_location
  avail_zone = var.avail_zone
  keyName = var.keyName
  public_subnet_id = module.network_infra.public_subnet_1.id  #network_infra module output resource
  instance_type = var.instance_type
  entry_script_location = var.entry_script_location
}

