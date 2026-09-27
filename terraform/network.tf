# ---------------------------------------------------------------
# Networking: VPC + public subnet + internet gateway + route table
# ---------------------------------------------------------------

# List of availability zones (data centres) in the chosen region
data "aws_availability_zones" "available" {
  state = "available"
}

# 1. VPC - our own private network in AWS
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # needed so the EC2 instance gets a public DNS name

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 2. Internet gateway - the VPC's door to the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 3. Public subnet - servers here get a public IP automatically
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# 4. Route table - "send all internet traffic (0.0.0.0/0) to the internet gateway"
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# 5. Attach the route table to the subnet (this is what makes the subnet "public")
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
