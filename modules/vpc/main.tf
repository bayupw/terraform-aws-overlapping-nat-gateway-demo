resource "aws_vpc" "this" {
  cidr_block = var.cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = { 
      "Name" = var.vpc_name
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.secondary_cidr
}

resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = { 
    "Name" = "${var.vpc_name}-igw" 
    }
}

########################
# Non-Routable Subnets #
########################

resource "aws_subnet" "routable_subnets" {
  count = length(var.routable_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(concat(var.routable_subnets, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = true

  tags = {
      "Name" = format(
        "${var.vpc_name}-${var.routable_subnets_suffix}-%s",
        element(var.azs, count.index),)
    }

  depends_on = [aws_vpc.this, aws_vpc_ipv4_cidr_block_association.this]
}

resource "aws_route_table" "routable_subnets" {
  count = length(var.routable_subnets)

  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.vpc_name}-${var.routable_subnets_suffix}-${element(var.azs, count.index)}" 
  }

  depends_on = [aws_vpc.this]
}

resource "aws_route_table_association" "routable_subnets" {
  count = length(var.routable_subnets)

  subnet_id      = element(aws_subnet.routable_subnets[*].id, count.index)
  route_table_id = aws_route_table.routable_subnets[count.index].id
}

resource "aws_route" "routable_subnets" {
  count = var.create_igw && var.create_default_route ? length(var.routable_subnets) : 0

  route_table_id         = aws_route_table.routable_subnets[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

########################
# Non-Routable Subnets #
########################

resource "aws_subnet" "non_routable_subnets" {
  count = length(var.non_routable_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(concat(var.non_routable_subnets, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = true

  tags = {
      "Name" = format(
        "${var.vpc_name}-${var.non_routable_subnets_suffix}-%s",
        element(var.azs, count.index),)
    }

  depends_on = [aws_vpc.this]
}

resource "aws_route_table" "non_routable_subnets" {
  count = length(var.non_routable_subnets)

  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.vpc_name}-${var.non_routable_subnets_suffix}-${element(var.azs, count.index)}" 
  }

    depends_on = [aws_vpc.this]
}

resource "aws_route_table_association" "non_routable_subnets" {
  count = length(var.non_routable_subnets)

  subnet_id      = element(aws_subnet.non_routable_subnets[*].id, count.index)
  route_table_id = aws_route_table.non_routable_subnets[count.index].id
}

resource "aws_route" "non_routable_subnets" {
  count = var.create_igw && var.create_default_route ? length(var.non_routable_subnets) : 0

  route_table_id         = aws_route_table.non_routable_subnets[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}