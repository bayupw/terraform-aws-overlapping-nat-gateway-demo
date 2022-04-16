output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = module.alb.lb_dns_name
}

output "alb_private_ip_1" {
  description = "ALB Private IPs"
  value       = data.aws_network_interface.alb_eni_0.private_ip
}

output "alb_private_ip_2" {
  description = "ALB Private IPs"
  value       = data.aws_network_interface.alb_eni_1.private_ip
}

output "instance_client_private_ip" {
  description = "Client Private IP"
  value       = module.client.aws_instance.private_ip
}

output "instance_web_private_ip" {
  description = "Web Server Private IP"
  value       = module.web_server.aws_instance.private_ip
}

output "natgw_private_ip" {
  description = "NAT Gateway Private IP"
  value       = aws_nat_gateway.this.private_ip
}