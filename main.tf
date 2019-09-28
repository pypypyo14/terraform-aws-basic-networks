data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name    = "${var.project}_terraform_vpc"
    project = var.project
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name    = "${var.project}_terraform_igw"
    project = var.project
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_cidr)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = element(var.public_cidr, count.index)
  tags = {
    Name    = "${var.project}_terraform_publicsubnet_${count.index}"
    project = var.project
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_cidr)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = element(var.private_cidr, count.index)
  tags = {
    Name    = "${var.project}_terraform_pribatesubnet_${count.index}"
    project = var.project
  }
}

resource "aws_eip" "nat" {
  count = length(var.public_cidr)
  vpc   = true
  tags = {
    Name    = "${var.project}_terraform_nateip_${count.index}"
    project = var.project
  }
}

resource "aws_nat_gateway" "gw" {
  count         = length(var.public_cidr)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name    = "${var.project}_terraform_natgw_${count.index}"
    project = var.project
  }
}

resource "aws_egress_only_internet_gateway" "egress" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name    = "${var.project}_terraform_publicrt"
    project = var.project
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.publicrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table" "privatert" {
  count  = length(var.private_cidr)
  vpc_id = aws_vpc.main.id
  tags = {
    Name    = "${var.project}_terraform_privatert${count.index}"
    project = var.project
  }
}

resource "aws_route" "private" {
  count                  = length(var.public_cidr)
  route_table_id         = aws_route_table.privatert[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.privatert[count.index].id
}
