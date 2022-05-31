variable "network_component" {
    description = "each network component name and cidr_block"
    type = list(object({

        name = string         #pass name as tag for each network component
        cidr_block = string   #pass cidr_block for each component cidr_block 

    }))
}
variable "avail_zone" {}
variable "env_prefix" {}