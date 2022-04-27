# Create random string
resource "random_string" "this" {
  count = var.random_suffix ? 1 : 0

  length  = var.random_string_length
  number  = true
  special = false
  upper   = false
}

# Create IAM Role
resource "aws_iam_role" "this" {
  name               = var.random_suffix ? "${var.ssm_instance_role_name}-${lower(random_string.this[0].id)}" : var.ssm_instance_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "this" {
  name = var.random_suffix ? "${var.ssm_instance_profile_name}-${lower(random_string.this[0].id)}" : var.ssm_instance_profile_name
  role = aws_iam_role.this.name
}

# Create IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}