output "tgw" {
  description = "TGW object"
  value       = aws_ec2_transit_gateway.this
}

output "tgw_rtb" {
  description = "TGW rtb object"
  value       = aws_ec2_transit_gateway_route_table.this
}

output "tgw_vpc_attachments" {
  description = "TGW VPC attachment objects"
  value       = aws_ec2_transit_gateway_vpc_attachment.this
}

output "vpcs" {
  description = ""
  value       = data.aws_vpc.vpcs
}
