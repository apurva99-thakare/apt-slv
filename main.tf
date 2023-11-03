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



resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.apurva.id
  cidr_block = "192.168.3.0/24"

  tags = {
    Name = "private"
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




# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.apurva.id

  tags = {
    Name        = "private-route-table"
    Environment = "deployment environment"
  }
}

# Subnet association for public route table
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_instance" "apurva-jenkins" {
  ami      = "ami-057d718060ad10dd3"
  instance_type = "t3.medium"
  key_name = "server-practice-key-mumbai"
  tags = {
    Name = "Apurva"
  }
}

