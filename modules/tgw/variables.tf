variable "description" {
  description = "Description of the EC2 Transit Gateway"
  type        = string
  default     = "tgw"
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the TGW is created with the current default Amazon ASN."
  type        = number
  default     = 64512
}

variable "default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default association route table"
  type        = bool
  default     = false
}

variable "default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default propagation route table"
  type        = bool
  default     = false
}

variable "dns_support" {
  description = "Should be true to enable DNS support in the TGW"
  type        = bool
  default     = true
}

variable "vpc_attachments" {
  description = "Maps of maps of VPC details to attach to TGW. Type 'any' to disable type validation by Terraform."
  type        = any
  default     = {}
}
