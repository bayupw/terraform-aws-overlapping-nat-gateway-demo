data "aws_region" "current" {}

# Create 3 digit random string
resource "random_string" "this" {
  length  = 3
  number  = true
  special = false
  upper   = false
}

# Create IAM role and IAM instance profile for SSM
module "ssm_instance_profile" {
  source  = "bayupw/ssm-instance-profile/aws"
  version = "1.0.0"
}

# Create TGW
module "tgw" {
  source = "./modules/tgw"

  vpc_attachments = {
    vpc_a = {
      vpc_id                                          = module.vpc_a.vpc.id
      subnet_ids                                      = [module.vpc_a.routable_subnets[0].id, module.vpc_a.routable_subnets[1].id]
      dns_support                                     = true
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tag                                             = "VPC-A-Att-${random_string.this.id}"
      tgw_route_cidr_block                            = module.vpc_a.secondary_cidr
    }
    vpc_b = {
      vpc_id                                          = module.vpc_b.vpc.id
      subnet_ids                                      = [module.vpc_b.routable_subnets[0].id]
      dns_support                                     = true
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tag                                             = "VPC-B-Att-${random_string.this.id}"
      tgw_route_cidr_block                            = module.vpc_b.secondary_cidr
    }
  }

  depends_on = [module.vpc_a, module.vpc_b]
}

# Create route to VPC-A routable subnet
resource "aws_ec2_transit_gateway_route" "vpc_a_route" {
  transit_gateway_route_table_id = module.tgw.tgw_rtb.id
  transit_gateway_attachment_id  = module.tgw.tgw_vpc_attachments.vpc_a.id
  destination_cidr_block         = module.vpc_a.secondary_cidr

  depends_on = [module.tgw]
}

# Create route to VPC-B routable subnet
resource "aws_ec2_transit_gateway_route" "vpc_b_route" {
  transit_gateway_route_table_id = module.tgw.tgw_rtb.id
  transit_gateway_attachment_id  = module.tgw.tgw_vpc_attachments.vpc_b.id
  destination_cidr_block         = module.vpc_b.secondary_cidr

  depends_on = [module.tgw]
}

# Create tgw route table associate to VPC-A
resource "aws_ec2_transit_gateway_route_table_association" "vpc_a_assoc" {
  transit_gateway_attachment_id  = module.tgw.tgw_vpc_attachments.vpc_a.id
  transit_gateway_route_table_id = module.tgw.tgw_rtb.id

  depends_on = [module.tgw]
}

# Create tgw route table associate to VPC-B
resource "aws_ec2_transit_gateway_route_table_association" "vpc_b_assoc" {
  transit_gateway_attachment_id  = module.tgw.tgw_vpc_attachments.vpc_b.id
  transit_gateway_route_table_id = module.tgw.tgw_rtb.id

  depends_on = [module.tgw]
}