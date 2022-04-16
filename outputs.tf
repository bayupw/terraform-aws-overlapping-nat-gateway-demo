output "instance_client" {
  description = "Client"
  value       = "${module.client.aws_instance.id} | Private IP: ${module.client.aws_instance.private_ip}"
}

output "instance_web" {
  description = "Web Server"
  value       = "${module.web_server.aws_instance.id} | Private IP: ${module.web_server.aws_instance.private_ip}"
}

output "alb" {
  description = "ALB"
  value       = "ALB DNS: ${module.alb.lb_dns_name}"
}