# Create VPC-A
module "vpc_a" {
  source = "./modules/vpc"

  cidr                 = "10.0.0.0/16"
  secondary_cidr       = "100.64.0.0/24"
  vpc_name             = "NATGW-VPC-A"
  azs                  = ["ap-southeast-2a"]
  non_routable_subnets = ["10.0.1.0/24"]
  routable_subnets     = ["100.64.0.0/24"]
}

# Create NAT Gateway
resource "aws_nat_gateway" "this" {
  connectivity_type = "private"
  subnet_id         = module.vpc_a.routable_subnets[0].id
}

# VPC-A Client EC2 instance in VPC-A
module "client" {
  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  instance_hostname           = "client-instance"
  vpc_id                      = module.vpc_a.vpc.id
  subnet_id                   = module.vpc_a.non_routable_subnets[0].id
  associate_public_ip_address = true
  private_ip                  = cidrhost(module.vpc_a.non_routable_subnets[0].cidr_block, 11)
  iam_instance_profile        = module.ssm_instance_profile.aws_iam_instance_profile

  depends_on = [module.vpc_a, module.ssm_instance_profile]
}

# Create route to VPC-B routable via TGW
resource "aws_route" "vpc_a_to_vpc_b" {
  count = length(module.vpc_a.routable_subnets_rtb)

  route_table_id         = module.vpc_a.routable_subnets_rtb[count.index].id
  destination_cidr_block = module.vpc_b.secondary_cidr
  transit_gateway_id     = module.tgw.tgw.id

  depends_on = [module.tgw]
}

# Create route to VPC-B routable via NAT Gateway
resource "aws_route" "vpc_a_to_natgw" {
  count = length(module.vpc_a.non_routable_subnets_rtb)

  route_table_id         = module.vpc_a.non_routable_subnets_rtb[count.index].id
  destination_cidr_block = module.vpc_b.secondary_cidr
  nat_gateway_id         = aws_nat_gateway.this.id

  depends_on = [aws_nat_gateway.this]
}