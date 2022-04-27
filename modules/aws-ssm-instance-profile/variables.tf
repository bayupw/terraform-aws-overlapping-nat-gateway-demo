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

# SSM IAM Role name
variable "ssm_instance_role_name" {
  description = "SSM IAM role name"
  type        = string
  default     = "ssm-role"
}

# SSM IAM Instance Profile name
variable "ssm_instance_profile_name" {
  description = "SSM instance profile name"
  type        = string
  default     = "ssm-instance-profile"
}