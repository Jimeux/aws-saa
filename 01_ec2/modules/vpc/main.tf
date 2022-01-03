resource "aws_vpc" "app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { App = var.app }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags   = { App = var.app }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
  tags   = { App = var.app }
}

resource "aws_subnet" "one" {
  vpc_id                  = aws_vpc.app.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                    = { App = var.app }
}

resource "aws_subnet" "two" {
  vpc_id                  = aws_vpc.app.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags                    = { App = var.app }
}

resource "aws_route_table_association" "one" {
  subnet_id      = aws_subnet.one.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "two" {
  subnet_id      = aws_subnet.two.id
  route_table_id = aws_route_table.public.id
}
