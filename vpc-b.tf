# Create VPC-B
module "vpc_b" {
  source = "./modules/vpc"

  cidr                 = "10.0.0.0/16"
  secondary_cidr       = "100.65.0.0/24"
  vpc_name             = local.vpc_b_name
  azs                  = ["ap-southeast-2a"]
  non_routable_subnets = ["10.0.0.0/24"]
  routable_subnets     = ["100.65.0.0/24"]
}

# Create NAT Gateway
resource "aws_nat_gateway" "this" {
  connectivity_type = "private"
  subnet_id         = module.vpc_b.routable_subnets[0].id
}

# VPC-A Client EC2 instance in VPC-A
module "client" {
  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  random_suffix                  = false
  instance_hostname              = local.client_hostname
  vpc_id                         = module.vpc_b.vpc.id
  subnet_id                      = module.vpc_b.non_routable_subnets[0].id
  private_ip                     = cidrhost(module.vpc_b.non_routable_subnets[0].cidr_block, 11)
  iam_instance_profile           = module.ssm_instance_profile.aws_iam_instance_profile
  associate_public_ip_address    = true
  enable_password_authentication = true
  random_password                = false
  instance_username              = var.username
  instance_password              = var.password
  key_name                       = var.key_name

  depends_on = [module.vpc_b, module.ssm_instance_profile]
}

# Create route to VPC-A routable via TGW
resource "aws_route" "vpc_b_to_vpc_a" {
  count = 1

  route_table_id         = module.vpc_b.routable_subnets_rtb[count.index].id
  destination_cidr_block = module.vpc_a.secondary_cidr
  transit_gateway_id     = module.tgw.tgw.id

  depends_on = [module.tgw]
}

# Create route to VPC-B routable via NAT Gateway
resource "aws_route" "vpc_b_to_natgw" {
  count = 1

  route_table_id         = module.vpc_b.non_routable_subnets_rtb[count.index].id
  destination_cidr_block = module.vpc_a.secondary_cidr
  nat_gateway_id         = aws_nat_gateway.this.id

  depends_on = [aws_nat_gateway.this]
}