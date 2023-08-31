provider "aws" {
  region = "ap-southeast-1"
  access_key = "AKIA2ZKIEPJA4WQUW2V2"
  secret_key = "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"
}

resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "vpc2" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.vpc1.id
}

resource "aws_internet_gateway" "gw2" {
  vpc_id = aws_vpc.vpc2.id
}

resource "aws_vpc_peering_connection" "vpc_peering_connection" {
  peer_vpc_id  = aws_vpc.vpc1.id
  vpc_id = aws_vpc.vpc2.id
}

resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_vpc_peering_connection.vpc_peering_connection.id
  }
}

resource "aws_route_table" "route_table2" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_vpc_peering_connection.vpc_peering_connection.id
  }
}

resource "aws_subnet" "subnet1a" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "vpc1-subnet1a"
  }
}

resource "aws_subnet" "subnet1b" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "vpc1-subnet1b"
  }
}

resource "aws_subnet" "subnet2a" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.1.0.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "vpc2-subnet2a"
  }
}

resource "aws_subnet" "subnet2b" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "vpc2-subnet2b"
  }
}

resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "sg"
  vpc_id      = aws_vpc.vpc1.id
}

resource "aws_security_group" "sg2" {
  name        = "sg2"
  description = "sg"
  vpc_id      = aws_vpc.vpc2.id
}
