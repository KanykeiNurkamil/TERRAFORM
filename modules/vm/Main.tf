
# 1. Create vpc 

resource "aws_vpc" "terraform-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "tarraform-vpc"
  }
}

# 2. Create Internet Gateway 

resource "aws_internet_gateway" "terraform-ig" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "terraform-ig"
  }
}

# 3. Create Custom Route Table

resource "aws_route_table" "terraform-rt" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-ig.id
  }

  route {
    ipv6_cidr_block    = "::/0"
    gateway_id         = aws_internet_gateway.terraform-ig.id
  }

  tags = {
    Name = "terraform-rt"
  }
}

# 4. Create a Subnet

resource "aws_subnet" "terraform-subnet" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = var.subnet_prefix
  availability_zone= var.availability_zone 

  tags = {
    Name = "terraform-subnet"
  }
}
# 5. Associate subnet with Route Table 

resource "aws_route_table_association" "terraform-rta" {
  subnet_id      = aws_subnet.terraform-subnet.id
  route_table_id = aws_route_table.terraform-rt.id
}

# 6. Create Security Group to allow port 22,80,443

resource "aws_security_group" "terraform-sg" {
  name        = "allow_web-traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.terraform-vpc.id

  dynamic ingress {
    for_each = [ "80", "22","443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "tcp"
  }
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "terraform-webserver" {
  subnet_id       = aws_subnet.terraform-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.terraform-sg.id]

}
# 8. Assign an Elastic IP to the newtork interface craeted in step 7 

resource "aws_eip" "one" {
  vpc                        = true
  network_interface          = aws_network_interface.terraform-webserver.id
  associate_with_private_ip  = "10.0.1.50"
  depends_on                 = [aws_internet_gateway.terraform-ig]
}

# 9. Create Ubuntu Servers and install/enable httpd

data "aws_ami" "instances_ami" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name" 
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20201026"]

  }
}

resource "aws_instance" "terraform-instances" {
  ami                  = data.aws_ami.instances_ami.id
  instance_type        = var.instance_type 
  availability_zone    = var.availability_zone
  count                = var.instance_count 
  key_name             = "terraform2"

  network_interface {
    device_index          = 0
    network_interface_id  = aws_network_interface.terraform-webserver.id 
  } 

  user_data = file("install_apache.sh")

  tags = {
    Name = "terraform-server"
  }
}