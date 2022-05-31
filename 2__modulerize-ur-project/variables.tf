variable network_component {
  description = "list of objects includes cidr-blocks for vpc and subnets "
  type = list(object({
    name = string         #pass name as tag for each network component
    cidr_block = string   #pass cidr_block for each component cidr_block 

  }))
}

variable env_prefix {}
variable "image_name_filter" {}
variable avail_zone {}
variable "keyName" {}
variable "my_ip" {}
variable "public_key_location" {}
variable "instance_type" {}
variable "entry_script_location" {}

