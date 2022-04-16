resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = var.default_route_table_association == true ? "enable" : "disable"
  default_route_table_propagation = var.default_route_table_propagation == true ? "enable" : "disable"
  dns_support                     = var.dns_support == true ? "enable" : "disable"

  tags = {
    Name = var.description
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
    Name = "routable-tgw-rtb"
  }
}

data "aws_vpc" "vpcs" {
  for_each = aws_ec2_transit_gateway_vpc_attachment.this
  id = each.value.vpc_id
}

/* locals {
  tgw_attachment = {
      for k1, v1 in aws_ec2_transit_gateway_vpc_attachment.this : k1 => v1.id
  }

  tgw_second_cidr = {
        for k2, v2 in data.aws_vpc.vpcs : k2 => v2.cidr_block_associations[1].cidr_block
  }

  tgw_routes = {
      for vpc, attachment_id in local.tgw_attachment:
      attachment_id => lookup(local.tgw_second_cidr, vpc, null)
  }
} */