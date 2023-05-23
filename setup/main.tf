terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

# VPCs and Subnets
resource "aws_vpc" "experimental" {
  # CIDR block for the internal + DMZ subnets
  cidr_block = var.experimental_internal_cidr

  tags = {
    Name = "Experimental VPC"
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "public" {
  # Secondary CIDR block for the internal subnet
  depends_on = [
    aws_vpc.experimental
  ]
  vpc_id     = aws_vpc.experimental.id
  cidr_block = var.experimental_public_cidr
}

resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.public
  ]
  vpc_id                  = aws_vpc.experimental.id
  cidr_block              = var.experimental_public_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true


  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "internal" {
  vpc_id                  = aws_vpc.experimental.id
  cidr_block              = var.experimental_internal_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Internal Subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  # Internet gateway for public
  vpc_id = aws_vpc.experimental.id

  tags = {
    Name = "Internet Gateway"
  }
}

# Route Tables
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.experimental.id

  route {
    # Route traffic for Internet to Internet Gateway
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Route Table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.routetable.id
}

resource "aws_route_table_association" "internal" {
  subnet_id      = aws_subnet.internal.id
  route_table_id = aws_route_table.routetable.id
}

# Security Groups
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.experimental.id

  ingress {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

# Router
resource "aws_network_interface" "router_external" {
  subnet_id       = aws_subnet.public.id
  private_ips     = [var.router_external_ip]
  security_groups = [aws_security_group.allow_all.id]
  # Ubuntu is used as a router and thus for traffic to be forwarded to it, this check needs to be disabled
  # since the IP of pfsense is not in the source or destination of the packet
  source_dest_check = false
}

resource "aws_network_interface" "router_internal" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = [var.router_internal_ip]
  security_groups = [aws_security_group.allow_all.id]
  # Ubuntu is used as a router and thus for traffic to be forwarded to it, this check needs to be disabled
  # since the IP of pfsense is not in the source or destination of the packet
  source_dest_check = false
}

resource "aws_instance" "router" {
  ami               = "ami-055d15d9cfddf7bd3" # ubuntu server 20.04 LTS
  instance_type     = "t2.micro"
  availability_zone = var.availability_zone
  key_name          = var.key_pair_name
  # set dependency as it requires Ubuntu Web Server to be set up first before router can pull the filebeat files
  depends_on = [aws_instance.ubuntu_web_server]

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.router_internal.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.router_external.id
  }


  user_data = (var.is_splunk ?
    file("${path.module}/setup_scripts/Splunk/router_setup.sh")
    : (var.is_elk ?
      file("${path.module}/setup_scripts/ELK/router_setup.sh")
    : file("${path.module}/setup_scripts/Vanilla/router_setup.sh"))
  )

  tags = {
    Name = "router"
  }
}

# SIEM
resource "aws_network_interface" "siem" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = [var.siem_ip]
  security_groups = [aws_security_group.allow_all.id]
}

resource "aws_instance" "siem" {
  ami               = "ami-055d15d9cfddf7bd3" # ubuntu server 20.04 LTS
  instance_type     = "t2.medium"
  availability_zone = var.availability_zone
  key_name          = "Terraform"

  # Add a larger storage device
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.siem.id
  }

  user_data = (var.is_splunk ?
    file("${path.module}/setup_scripts/Splunk/siem_setup.sh")
    : (var.is_elk ?
      file("${path.module}/setup_scripts/ELK/siem_setup.sh")
    : file("${path.module}/setup_scripts/Vanilla/siem_setup.sh"))
  )

  tags = {
    Name = "siem"
  }
}

# Domain Controller
resource "aws_network_interface" "DC" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = [var.DC_ip]
  security_groups = [aws_security_group.allow_all.id]
}

resource "aws_instance" "DC" {
  ami               = "ami-0bc64185df5784cc3" # Windows_Server-2019-English-Full-Base-2022.06.15
  instance_type     = "t2.medium"
  availability_zone = var.availability_zone
  key_name          = var.key_pair_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.DC.id
  }

  user_data = (var.is_splunk ?
    file("${path.module}/setup_scripts/Splunk/DC_setup.ps1")
    : (var.is_elk ?
      file("${path.module}/setup_scripts/ELK/DC_setup.ps1")
    : file("${path.module}/setup_scripts/Vanilla/DC_setup.ps1"))
  )

  tags = {
    Name = "DC"
  }
}

# Attacker
resource "aws_network_interface" "attacker" {
  subnet_id       = aws_subnet.public.id
  private_ips     = [var.attacker_ip]
  security_groups = [aws_security_group.allow_all.id]
}

resource "aws_instance" "attacker" {
  ami               = "ami-039fea51dbe2592e2" # Kali 2022
  instance_type     = "t2.micro"
  availability_zone = var.availability_zone
  key_name          = "Terraform"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.attacker.id
  }

  user_data = (var.is_splunk ?
    file("${path.module}/setup_scripts/Splunk/attacker_setup.sh")
    : (var.is_elk ?
      file("${path.module}/setup_scripts/ELK/attacker_setup.sh")
    : file("${path.module}/setup_scripts/Vanilla/attacker_setup.sh"))
  )

  tags = {
    Name = "attacker"
  }
}

# Ubuntu Web Server
resource "aws_network_interface" "ubuntu_web_server" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = [var.ubuntu_web_server_ip]
  security_groups = [aws_security_group.allow_all.id]
}

resource "aws_instance" "ubuntu_web_server" {
  ami               = "ami-055d15d9cfddf7bd3" # ubuntu server 20.04 LTS
  instance_type     = "t2.micro"
  availability_zone = var.availability_zone
  key_name          = var.key_pair_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ubuntu_web_server.id
  }

  user_data = (var.is_splunk ?
    file("${path.module}/setup_scripts/Splunk/ubuntu_web_server_setup.sh")
    : (var.is_elk ?
      file("${path.module}/setup_scripts/ELK/ubuntu_web_server_setup.sh")
    : file("${path.module}/setup_scripts/Vanilla/ubuntu_web_server_setup.sh"))
  )

  tags = {
    Name = "Ubuntu Web Server"
  }
}

# Windows Host
resource "aws_network_interface" "windows_host" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = [var.windows_host_ip]
  security_groups = [aws_security_group.allow_all.id]
}

resource "aws_instance" "windows_host" {
  ami               = "ami-0bc64185df5784cc3" # Windows_Server-2019-English-Full-Base-2022.06.15
  instance_type     = "t2.micro"
  availability_zone = var.availability_zone
  key_name          = var.key_pair_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.windows_host.id
  }

  user_data = (var.is_splunk ?
    file("${path.module}/setup_scripts/Splunk/windows_host_setup.ps1")
    : (var.is_elk ?
      file("${path.module}/setup_scripts/ELK/windows_host_setup.ps1")
    : file("${path.module}/setup_scripts/Vanilla/windows_host_setup.ps1"))
  )

  tags = {
    Name = "Windows Host"
  }
}