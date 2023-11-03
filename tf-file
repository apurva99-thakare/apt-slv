terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# VPC
resource "aws_vpc" "apurva" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "apurva"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.apurva.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.apurva.id
  cidr_block = "192.168.2.0/24"

  tags = {
    Name = "public2"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.apurva.id
  cidr_block = "192.168.3.0/24"

  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.apurva.id
  cidr_block = "192.168.4.0/24"

  tags = {
    Name = "private2"
  }
}

resource "aws_internet_gateway" "igw-apurva" {
  vpc_id = aws_vpc.apurva.id

  tags = {
    Name = "igw-apurva"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.apurva.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-apurva.id
  }

  tags = {
    Name = "public"
  }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc = true
}


# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  tags = {
    Name        = "apurva-nat"
    Environment = "deployment environment"
  }
}


# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.apurva.id

  tags = {
    Name        = "private-route-table"
    Environment = "deployment environment"
  }
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Default Security Group of VPC
resource "aws_security_group" "vpc-sg" {
  name        = "vpc-sg"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id = aws_vpc.apurva.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks = [aws_vpc.apurva.cidr_block]

  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "tcp"
    self      = "true"
  }

  tags = {
    Environment = "deployment environment"
  }
}

# Subnet association for public route table
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private2" {
  subnet_id = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}


resource "aws_instance" "apurva-jenkins" {
  ami      = "ami-057d718060ad10dd3"
  instance_type = "t3.medium"
  key_name = "server-practice-key-mumbai"
  tags = {
    Name = "Apurva-jenkins"
  }
  user_data = "<<-EOF
  #!/bin/bash
  sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
  sudo yum upgrade -y
  sudo yum install fontconfig -y
  sudo yum install java-17* -y
  sudo yum install jenkins -y
  sudo systemctl enable jenkins
  sudo systemctl start jenkins
  EOF"
}

