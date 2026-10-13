terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket       = "gazaldevops-tfstate-820242917252"
    key          = "aws-rds-java/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
    profile      = "terraform-user"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.24"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Existing VPC created manually in AWS
resource "aws_vpc" "java_app" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "java-app-vpc"
  }
}

# Existing public subnet 1 created manually in AWS
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.java_app.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "java-app-public-subnet-1"
  }
}

# Existing public subnet 2 created manually in AWS
resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.java_app.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "java-app-public-subnet-2"
  }
}

# Existing private subnet 1 created manually in AWS
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.java_app.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "java-app-private-subnet-1"
  }
}

# Existing private subnet 2 created manually in AWS
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.java_app.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "java-app-private-subnet-2"
  }
}

# Existing Internet Gateway created manually in AWS
resource "aws_internet_gateway" "java_app" {
  vpc_id = aws_vpc.java_app.id

  tags = {
    Name = "java-app-igw"
  }
}

# Existing public route table created manually in AWS
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.java_app.id

  tags = {
    Name = "java-app-public-rt"
  }
}

# Existing public internet route
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.java_app.id
}

# Existing association between public subnet 1 and the public route table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Existing association between public subnet 2 and the public route table
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Existing private route table created manually in AWS
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.java_app.id

  tags = {
    Name = "java-app-private-rt"
  }
}

# Existing private route through the NAT Gateway
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.java_app.id
}

# Existing association between private subnet 1 and the private route table
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

# Existing association between private subnet 2 and the private route table
resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# Existing Regional NAT Gateway
resource "aws_nat_gateway" "java_app" {
  vpc_id            = aws_vpc.java_app.id
  availability_mode = "regional"

  lifecycle {
    ignore_changes = [allocation_id]
  }

  # Preserve the existing Regional NAT Gateway address configuration.
  availability_zone_address {
    allocation_ids    = [aws_eip.nat.id]
    availability_zone = "us-east-1a"
  }

  tags = {
    Name = "java-app-nat-gateway"
  }
}

# Existing Elastic IP used by the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}
