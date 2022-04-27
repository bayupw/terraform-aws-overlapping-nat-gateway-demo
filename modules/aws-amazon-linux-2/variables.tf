# Boolean to determine if name will be appended with random string
variable "random_suffix" {
  description = "Set to true to append random suffix"
  type        = bool
  default     = true
}

# Length of random string to be appended to the name
variable "random_string_length" {
  description = "Random string length"
  type        = number
  default     = 3
}

# Boolean to determine if random password will be generated
variable "random_password" {
  description = "Set to true to generate random password"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance"
  type        = string
  default     = null
}

variable "instance_hostname" {
  description = "EC2 instance hostname"
  type        = string
  default     = "amazon-linux-2"
}

variable "instance_username" {
  description = "Instance username"
  type        = string
  default     = "ec2-user"
}

variable "instance_password" {
  description = "Instance password"
  type        = string
  default     = "Amazon123#"
}

variable "iam_instance_profile" {
  description = "Name of an IAM Instance Profile to launch the instance with"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = null
}

variable "enable_password_authentication" {
  description = "Set to true to enable password authentication"
  type        = bool
  default     = false
}

variable "install_httpd" {
  description = "Set to true to install httpd"
  type        = bool
  default     = true
}

variable "allow_my_public_ip" {
  description = "Set to true to add client public IP to ingress"
  type        = bool
  default     = true
}

# when using custom_ingress_cidrs, rfc1918 and my_public_ip IP will be ignored
variable "custom_ingress_cidrs" {
  description = "List of IP addreses/network to be allowed in the ingress security group"
  type        = list(string)
  default     = null # sample ["1.2.3.4/32"] or ["1.2.3.4/32", "10.0.0.0/8"] 
}

locals {
  rfc1918       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  my_public_ip  = "${chomp(data.http.my_public_ip.body)}/32"
  ingress_cidrs = concat(local.rfc1918, [local.my_public_ip])

  instance_password           = var.random_password ? random_password.this[0].result : var.instance_password
  password_bootstrap          = var.enable_password_authentication ? local.password_bootstrap_template : ""
  password_bootstrap_template = <<EOF
sudo sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
sudo systemctl restart sshd
echo ${var.instance_username}:${local.instance_password} | sudo chpasswd
EOF

  httpd_bootstrap          = var.install_httpd ? local.httpd_bootstrap_template : ""
  httpd_bootstrap_template = <<EOF
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>This is ${var.instance_hostname} $(hostname -f)</h1>" > /var/www/html/index.html
EOF
}