#PROVIDER
provider "aws" {
    region  = "eu-central-1"
    access_key = "xxxxxxx"
    secret_key = "xxxxxxx"
}


#AMI UBUNTU
data "aws_ami"  "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values =["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"] #Canonical
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "key_pair" {
  key_name   = "one-key-pair"  
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Save file
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

resource "aws_instance" "web" {
    ami = "ami-0d500797138456fbb"
    instance_type = "t2.micro"
    tags = {
        Name = "web-server"
    }
    
    user_data = file("startup.sh")
    subnet_id              = aws_subnet.public-subnet.id
    vpc_security_group_ids = [aws_security_group.aws-vm-sg.id]
    source_dest_check      = false
    key_name = "one-key-pair"	// specific keypair present on AWS
    associate_public_ip_address = true
  
  # root disk
  root_block_device {
    volume_size           = 30
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  } 
}
#--------------------------------------------------------
/*
# Define our VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}


# Define the public subnet
resource "aws_subnet" "public-subnet" {
  cidr_block       = "10.0.1.0/24"
  vpc_id = "${aws_vpc.main.id}"
}
*/
#---------------------------------------------
# Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
}
# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr
 # availability_zone = var.aws_az
}
# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}
# Define the public route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
# Assign the public route table to the public subnet
resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

# SECURITY GROUP
# Define the security group for the EC2 Instance
resource "aws_security_group" "aws-vm-sg" {
  name        = "vm-sg"
  description = "Allow incoming connections"
  vpc_id      = aws_vpc.vpc.id  
  ingress{
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 8
  to_port     = 0
  protocol    = "icmp"
  description = "Allow ping from internet"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming RDP connections (Windows)"
  }  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections (Linux)"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  tags = {
    Name = "windows-sg"
  }
}




























