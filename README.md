## Introduction

For an Automated Infrastructure Provisioning We are going to use a common IAC tool "Terraform" which:
	- Automate and manage your infrastructure. 
	- Open source, Declarative, and universal IAC tool which supports different cloud providers & different technologies


> #### How does terraform work?

check Terraform Architecture:
![Terraform Architecture](Terraform-architecture.png)

It has two main components make up its architecture:
	- Core: figuers out what needs to be done by tarcking "state" and applying the "terraform.tf" desired configs.
	- Providers: what gives you the possibility to create infrastructure.
	
## Instructions

the following are instructions that anyone can use to deploy a terraform project,
also try to follow up using *[main.tf](main.tf) file to test the below instructions:

> ### initialize

    > 'terraform init'

    	- like installing dependencies in other programming projects
	- will install provider and all the required components in the script

	
> ### preview terraform actions

    > 'terraform plan'

        - compare the current aws state with the desired state in the config.tf file, so
        - it will show u what is going to be applied 
        
> ### apply config.tf file

    terraform apply         
    terraform apply -auto-approve
        -without asking for confirmation

    
> ### apply configuration with variables

    terraform apply -var-file terraform-dev.tfvars

        - by default, when issuing apply command, it will looks for the variables file with exact file name called: terraform.tfvars , but
        - if it was in another name like: terraform-dev.tfvars, it could not recognize it, so it will spin up an error
        - so we should manually pass the vars file

> ### destroy everything from tf files

    terraform destroy

> ### destroy a single resource

    terraform destroy -target aws_vpc.myapp-vpc

        - the most effecient way if u want to delete specific resource is to delete or comment out this resource then issue the command > terraform apply   
        - so if u are working on a team, all should know this resource was deleted, but
        - if u used > terraform destroy , the configs section for the destroyed resource will remain in the config.tf file as it was, and that will make a conflict, but
        - you can issue the > terraform plan command to check the differnece between the configs and the current state
        

> ### show resources and components from current state with "tfstate" file

    terraform state list
        
        - tfstate file: track the current state of the provider resources, file created after first apply comd 
        - state list: lists all the resources in the current state on aws, 
        - resources which created after last apply command

> ### show current state of a specific resource/data

    terraform state show aws_vpc.myapp-vpc

        - instead of navigating to aws GUI to see all the attributes for a specific resource, u can see any attribute from the state command
        - NOTE: there is attributes that gets generated automatically by aws, so state file has all that information, so you can get resource id, IP-address, arn, and others 
        
        
> ### set avail_zone as custom tf environment variable - before apply

    export TF_VAR_avail_zone="eu-west-3a"   

