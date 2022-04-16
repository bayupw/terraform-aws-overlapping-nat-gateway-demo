resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = var.default_route_table_association == true ? "enable" : "disable"
  default_route_table_propagation = var.default_route_table_propagation == true ? "enable" : "disable"
  dns_support                     = var.dns_support == true ? "enable" : "disable"

  tags = {
    Name        = var.description
    Environment = "NatGwDemo"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.vpc_attachments

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids

  dns_support                                     = try(each.value.dns_support, true) ? "enable" : "disable"
  transit_gateway_default_route_table_association = try(each.value.transit_gateway_default_route_table_association, false)
  transit_gateway_default_route_table_propagation = try(each.value.transit_gateway_default_route_table_propagation, false)

  tags = {
    Name = each.value.tag
  }
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = {
    Name        = "routable-tgw-rtb"
    Environment = "NatGwDemo"
  }
}

data "aws_vpc" "vpcs" {
  for_each = aws_ec2_transit_gateway_vpc_attachment.this
  id       = each.value.vpc_id
}