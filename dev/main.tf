provider "aws" {
  region = "us-east-2"
}
module "vm_module" {
    source = "/Users/kanykeinurkamilkyzy/Desktop/NEW/TERRAFORM/modules/vm"
    vpc_cidr_block= "10.0.0.0/16"
    subnet_prefix = "10.0.1.0/24"
    availability_zone = "us-east-2a"
    instance_type = "t2.micro"
    instance_count = "1" 
}