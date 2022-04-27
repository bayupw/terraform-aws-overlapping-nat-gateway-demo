# AWS Amazon Linux EC2 Instance

Terraform module to create Security Group and Amazon Linux 2 EC2 instance

## Usage with minimal customisation

```hcl
module "amazon_linux_2" {
  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  vpc_id = "vpc-0a1b2c3d4e"
  subnet_id = "subnet-0a1b2c3d4e"
  key_name = "ec2-keypair"
}
```

## Usage with SSM module

```hcl
module "ssm_instance_profile" {
  source  = "bayupw/ssm-instance-profile/aws"
  version = "1.0.0"
}

module "amazon_linux_2" {
  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  vpc_id = "vpc-0a1b2c3d4e"
  subnet_id = "subnet-0a1b2c3d4e"
  key_name = "ec2-keypair"
}
```

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/bayupw/terraform-aws-amazon-linux-2/issues/new) section.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/bayupw/terraform-aws-amazon-linux-2/tree/master/LICENSE) for full details.