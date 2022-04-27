# Create random string
resource "random_string" "this" {
  count = var.random_suffix ? 1 : 0

  length  = var.random_string_length
  number  = true
  special = false
  upper   = false
}

resource "random_password" "this" {
  count = var.random_password ? 1 : 0

  length  = 8
  special = false
}

# Retrieve amazon-linux-2 AMI details
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "amzn2-ami-hvm*"
}

# Retrieve my public IP address
data "http" "my_public_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Create Security Group
resource "aws_security_group" "this" {
  name        = var.random_suffix ? "${var.instance_hostname}-${lower(random_string.this[0].id)}/sg" : "${var.instance_hostname}/sg"
  description = "Allow all traffic from VPCs inbound and all outbound"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    # when using custom_ingress_cidrs, rfc1918 and my_public_ip IP will be ignored
    cidr_blocks = var.custom_ingress_cidrs != null ? var.custom_ingress_cidrs : local.ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.random_suffix ? "${var.instance_hostname}-${lower(random_string.this[0].id)}/sg" : "${var.instance_hostname}/sg"
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

# Create EC2 instance
resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  iam_instance_profile        = var.iam_instance_profile

  user_data = templatefile("${path.module}/bootstrap.sh",
    {
      "hostname"           = var.instance_hostname
      "password_bootstrap" = local.password_bootstrap
      "httpd_bootstrap"    = local.httpd_bootstrap
    }
  )

  tags = {
    "Name" = var.random_suffix ? "${var.instance_hostname}-${lower(random_string.this[0].id)}" : var.instance_hostname
  }

  depends_on = [aws_security_group.this]
}