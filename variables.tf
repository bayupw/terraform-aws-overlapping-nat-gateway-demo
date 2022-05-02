variable "username" {
  description = "EC2 instance username"
  type        = string
  default     = "ec2-user"
}

variable "password" {
  description = "EC2 instance password"
  type        = string
  default     = "Aviatrix123#"
}

variable "key_name" {
  description = "Existing EC2 Key Pair"
  type        = string
  default     = "ec2_keypair"
}

locals {
  vpc_a_name         = "NatGw-Provider-VPC-A-${random_string.this.id}"
  vpc_b_name         = "NatGw-Consumer-VPC-B-${random_string.this.id}"
  client_hostname    = "natgwdemo-client-${random_string.this.id}"
  webserver_hostname = "natgwdemo-webserver-${random_string.this.id}"
  alb_name           = "natgwdemo-alb-${random_string.this.id}"
  albsg_name         = "natgwdemo-alb-sg-${random_string.this.id}"
}