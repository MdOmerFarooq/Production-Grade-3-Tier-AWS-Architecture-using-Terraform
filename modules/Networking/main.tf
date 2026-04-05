# Networking module to create VPC and subnets for different layers of the application

# Create VPC
resource "aws_vpc" "VPC" {
    cidr_block = var.vpc_cidr
    region = var.region
    tags = {
        Name = "${terraform.workspace}-vpc"
    }
}

# Create Public Subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.availability_zones)
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index) 
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${terraform.workspace}-public-subnet ${count.index + 1}"
  }
}

# Create Frontend Private Subnets (offset by 10)
resource "aws_subnet" "private_frontend" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10) # Offset by 10 to avoid overlap with public subnets
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${terraform.workspace}-frontend-subnet-${count.index + 1}"
  }
}

# Create Backend Private Subnets (offset by 20)
resource "aws_subnet" "private_backend" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20) # Offset by 20 to avoid overlap with public and frontend subnets
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${terraform.workspace}-backend-subnet-${count.index + 1}"
  }
}

# Create Database Private Subnets (offset by 30)

resource "aws_subnet" "private_db" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 30) # Offset by 30 to avoid overlap with public, frontend, and backend subnets
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${terraform.workspace}-db-subnet-${count.index + 1}"
  }
}

# create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "${terraform.workspace}-igw"
  }
}

# Create the Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0" # Route all traffic to the Internet Gateway
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${terraform.workspace}-public-rt"
  }
}

# Associate the Public Subnets with this Route Table
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


# create a public IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain   = "vpc"
  tags = {
    Name = "${terraform.workspace}-nat-eip"
  }
}

# Create NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = {
    Name = "${terraform.workspace}-nat-gw"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Create a Route Table for Private Subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${terraform.workspace}-private-rt"
  }
}

# Associate Frontend Subnets
resource "aws_route_table_association" "frontend_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_frontend[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Associate Backend Subnets
resource "aws_route_table_association" "backend_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_backend[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
