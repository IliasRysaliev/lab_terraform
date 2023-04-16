provider "aws" {
    region = "us-east-1"
}
resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  tags = {
    Name = "main"
  }
}
resource "aws_internet_gateway" "gw" { 
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet1"
  }
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "subnet2"
  }
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
resource "aws_route_table_association" "example_route_table_association1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.example_route_table.id
}
resource "aws_route_table_association" "example_route_table_association2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.example_route_table.id
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow_ssh"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "Amazonlinux" {
  ami = "ami-00c39f71452c08778" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = "terraform_ec2_key"
  tags = {
    Name = "Amazon"
  }
}
resource "aws_instance" "Ubuntu" {
  ami = "ami-007855ac798b5175e" # ubuntu 
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = "terraform_ec2_key"
  tags = {
    Name = "Ubuntu"
  }
}
resource "tls_private_key" "tls_connector" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.tls_connector.public_key_openssh

  tags = {
    Owner = "ilias"
  }
}

resource "local_file" "terraform_ec2_key_file" {
  content  = tls_private_key.tls_connector.private_key_pem
  filename = "terraform_ec2_key.pem"

  provisioner "local-exec" {
    command = "chmod 400 terraform_ec2_key.pem"
  }
}
resource "aws_subnet" "public" {
  cidr_block = "10.10.1.0/24"
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "public"
  }

  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
