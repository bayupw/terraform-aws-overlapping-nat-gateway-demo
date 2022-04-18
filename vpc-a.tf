# Create VPC-A
module "vpc_a" {
  source = "./modules/vpc"

  cidr                 = "10.0.0.0/16"
  secondary_cidr       = "100.64.0.0/24"
  vpc_name             = local.vpc_a_name
  azs                  = ["ap-southeast-2a", "ap-southeast-2b"]
  non_routable_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  routable_subnets     = ["100.64.0.0/25", "100.64.0.128/25"]
}

# Web Server EC2 instance in VPC-A
module "web_server" {
  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  random_suffix               = false
  instance_hostname           = local.webserver_hostname
  vpc_id                      = module.vpc_a.vpc.id
  subnet_id                   = module.vpc_a.non_routable_subnets[0].id
  associate_public_ip_address = true
  private_ip                  = cidrhost(module.vpc_a.non_routable_subnets[0].cidr_block, 11)
  iam_instance_profile        = module.ssm_instance_profile.aws_iam_instance_profile
  custom_ingress_cidrs        = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "100.65.0.0/24"]

  depends_on = [module.ssm_instance_profile]
}

# Create Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = local.albsg_name
  description = "Allow all traffic to alb"
  vpc_id      = module.vpc_a.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc_a.secondary_cidr, module.vpc_b.secondary_cidr]
  }

  tags = {
    Name        = local.albsg_name
    Environment = "NatGwDemo"
  }
}

# Create ALB
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name               = local.alb_name
  load_balancer_type = "application"
  internal           = true
  enable_http2       = false
  vpc_id             = module.vpc_a.vpc.id
  subnets            = [module.vpc_a.routable_subnets[0].id, module.vpc_a.routable_subnets[1].id]
  security_groups    = [aws_security_group.alb_sg.id, one(module.web_server.aws_instance.vpc_security_group_ids)]

  target_groups = [
    {
      name_prefix      = "walb-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = module.web_server.aws_instance.id
          port      = 80
        }
      ]
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Name        = local.alb_name
    Environment = "NatGwDemo"
  }

  depends_on = [module.web_server]
}

# Create route to VPC-A routable via TGW
resource "aws_route" "vpc_a_to_vpc_b" {
  count = 2

  route_table_id         = module.vpc_a.routable_subnets_rtb[count.index].id
  destination_cidr_block = module.vpc_b.secondary_cidr
  transit_gateway_id     = module.tgw.tgw.id

  depends_on = [module.tgw]
}

# Web ALB ENIs in VPC-A
data "aws_network_interfaces" "alb_enis" {
  filter {
    name   = "description"
    values = ["ELB ${module.alb.lb_arn_suffix}"]
  }

  depends_on = [module.alb]
}

# Web ALB ENI 0 details in VPC-A
data "aws_network_interface" "alb_eni_0" {
  id         = data.aws_network_interfaces.alb_enis.ids[0]
  depends_on = [module.alb, data.aws_network_interfaces.alb_enis]
}

# Web ALB ENI 1 details in VPC-A
data "aws_network_interface" "alb_eni_1" {
  id         = data.aws_network_interfaces.alb_enis.ids[1]
  depends_on = [module.alb, data.aws_network_interfaces.alb_enis]
}