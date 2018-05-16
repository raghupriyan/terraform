provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "eu-west-1"
}

resource "aws_vpc" "tftest" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "True"
}

resource "aws_subnet" "subnet1" {
  vpc_id     = "${aws_vpc.tftest.id}"
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "subnet2" {
  vpc_id     = "${aws_vpc.tftest.id}"
  cidr_block = "10.0.2.0/24"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.tftest.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.tftest.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.tftest.id}"
}

resource "aws_route" "public_route" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table_association" "public_route_association" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.eip1.id}"
  subnet_id     = "${aws_subnet.subnet1.id}"
}

resource "aws_eip" "eip1" {
  vpc = "True"
}

resource "aws_route" "private_route" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_nat_gateway.ngw.id}"
}

resource "aws_route_table_association" "private_route_association" {
  subnet_id      = "${aws_subnet.subnet2.id}"
  route_table_id = "${aws_route_table.private.id}"
}
