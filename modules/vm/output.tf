output "vpcID" {
    value = aws_vpc.terraform-vpc.id
}

output "instance_count" {
    value = var.instance_count
    description = "Number of instances running in this VPC"
}

output "private_ip" {
    value = aws_instance.terraform-instances.*.private_ip
    description = "The private IP address of the main server instance."
}

output "public_ip" {
    value = aws_instance.terraform-instances.*.public_ip
    description = "The public IP address of the main server instance."
}

output "instance_state" {
    value = aws_instance.terraform-instances.*.instance_state
    description = "The current state of the main server instance."
}
