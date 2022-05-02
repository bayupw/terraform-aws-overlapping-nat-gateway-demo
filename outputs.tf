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

output "client_ssm_session" {
  description = "Client Instance SSM command"
  value       = "aws ssm start-session --region ${data.aws_region.current.name} --target ${module.client.aws_instance.id}"
}

output "client_private_ip" {
  description = "Client Private IP"
  value       = module.client.aws_instance.private_ip
}

output "web_ssm_session" {
  description = "Client Instance SSM command"
  value       = "aws ssm start-session --region ${data.aws_region.current.name} --target ${module.web_server.aws_instance.id}"
}

output "web_private_ip" {
  description = "Web Server Private IP"
  value       = module.web_server.aws_instance.private_ip
}


output "natgw_private_ip" {
  description = "NAT Gateway Private IP"
  value       = aws_nat_gateway.this.private_ip
}