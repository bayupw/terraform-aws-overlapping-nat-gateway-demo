output "vpc" {
  description = "VPC object"
  value       = aws_vpc.this
}

output "secondary_cidr" {
  description = "VPC object"
  value       = var.secondary_cidr
}

output "routable_subnets" {
  description = "Routable subnets subnet objects"
  value       = aws_subnet.routable_subnets[*]
}

output "routable_subnets_rtb" {
  description = "Routable subnets route tables objects"
  value       = aws_route_table.routable_subnets[*]
}

output "non_routable_subnets" {
  description = "Non-routable subnets subnet objects"
  value       = aws_subnet.non_routable_subnets[*]
}

output "non_routable_subnets_rtb" {
  description = "Non-routable subnets route tables objects"
  value       = aws_route_table.non_routable_subnets[*]
}