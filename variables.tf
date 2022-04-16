locals {
  vpc_a_name         = "NatGw-VPC-A-${random_string.this.id}"
  vpc_b_name         = "NatGw-VPC-B-${random_string.this.id}"
  client_hostname    = "natgwdemo-client-${random_string.this.id}"
  webserver_hostname = "natgwdemo-webserver-${random_string.this.id}"
  alb_name           = "natgwdemo-alb-${random_string.this.id}"
  albsg_name         = "natgwdemo-alb-sg-${random_string.this.id}"
}