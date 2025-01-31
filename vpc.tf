resource "aws_vpc" "compass_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "compass_vpc"
  }
}

resource "aws_subnet" "publica-elb-A" {
  vpc_id                  = aws_vpc.compass_vpc.id
  cidr_block              = var.publica-elb-A
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "publica-elb-A"
  }
}

resource "aws_subnet" "publica-elb-B" {
  vpc_id                  = aws_vpc.compass_vpc.id
  cidr_block              = var.publica-elb-B
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "publica-elb-B"
  }
}

resource "aws_subnet" "privada-app-A" {
  vpc_id                  = aws_vpc.compass_vpc.id
  cidr_block              = var.privada-app-A
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "privada-app-A"
  }
}

resource "aws_subnet" "privada-app-B" {
  vpc_id                  = aws_vpc.compass_vpc.id
  cidr_block              = var.privada-app-B
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "privada-app-B"
  }
}

resource "aws_internet_gateway" "compass_igw" {
  vpc_id = aws_vpc.compass_vpc.id

  tags = {
    Name = "compass_igw"
  }
}

resource "aws_eip" "compass_eip" {
  associate_with_private_ip = true

  tags = {
    Name = "compass_eip"
  }
}

resource "aws_eip" "compass_eip_b" {
  associate_with_private_ip = true

  tags = {
    Name = "compass_eip_b"
  }
}

resource "aws_nat_gateway" "compass_nat_a" {
  allocation_id = aws_eip.compass_eip.id
  subnet_id     = aws_subnet.publica-elb-A.id

  tags = {
    Name = "compass_nat_a"
  }
}


resource "aws_nat_gateway" "compass_nat_b" {
  allocation_id = aws_eip.compass_eip_b.id
  subnet_id     = aws_subnet.publica-elb-B.id

  tags = {
    Name = "compass_nat_b"
  }
}

resource "aws_route_table" "rota-publica" {
  vpc_id = aws_vpc.compass_vpc.id

  route {
    gateway_id = aws_internet_gateway.compass_igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "rota-publica"
  }
}

resource "aws_route_table" "rota-privada-A" {
  vpc_id = aws_vpc.compass_vpc.id

  route {
    nat_gateway_id = aws_nat_gateway.compass_nat_a.id
    cidr_block     = "0.0.0.0/0"
  }
  tags = {
    Name = "rota-privada-A"
  }
}

resource "aws_route_table" "rota-privada-B" {
  vpc_id = aws_vpc.compass_vpc.id

  route {
    nat_gateway_id = aws_nat_gateway.compass_nat_b.id
    cidr_block     = "0.0.0.0/0"
  }
  tags = {
    Name = "rota-privada-B"
  }
}

resource "aws_route_table_association" "assoc-publica-elb-A" {
  subnet_id      = aws_subnet.publica-elb-A.id
  route_table_id = aws_route_table.rota-publica.id
}

resource "aws_route_table_association" "assoc-publica-elb-B" {
  subnet_id      = aws_subnet.publica-elb-B.id
  route_table_id = aws_route_table.rota-publica.id
}

resource "aws_route_table_association" "assoc-privada-app-A" {
  subnet_id      = aws_subnet.privada-app-A.id
  route_table_id = aws_route_table.rota-privada-A.id
}

resource "aws_route_table_association" "assoc-privada-app-B" {
  subnet_id      = aws_subnet.privada-app-B.id
  route_table_id = aws_route_table.rota-privada-B.id
}





