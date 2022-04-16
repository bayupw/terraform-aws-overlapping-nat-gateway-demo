variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "secondary_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "routable_subnets" {
  description = "A list of routable subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "routable_subnets_suffix" {
  description = "Suffix to append to routable subnets name"
  type        = string
  default     = "routable"
}

variable "non_routable_subnets" {
  description = "A list of non-routable subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "non_routable_subnets_suffix" {
  description = "Suffix to append to non-routable subnets name"
  type        = string
  default     = "non-routable"
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "create_igw" {
  description = "Controls if an Internet Gateway is created"
  type        = bool
  default     = true
}

variable "create_default_route" {
  description = "Controls if default route to IGW should be created"
  type        = bool
  default     = true
}