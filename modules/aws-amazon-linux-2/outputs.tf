output "aws_security_group" {
  description = "The created AWS Security Group aws_security_group as an object with all of it's attributes"
  value       = aws_security_group.this
}

output "aws_instance" {
  description = "The created AWS EC2 instance aws_instance as an object with all of it's attributes"
  value       = aws_instance.this
  sensitive   = false
}

output "instance_password" {
  description = "EC2 instance SSH password"
  value       = local.instance_password
  sensitive   = true
}

output "my_public_ip" {
  description = "My public IP"
  value       = local.my_public_ip
  sensitive   = true
}  