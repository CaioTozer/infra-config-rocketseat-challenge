terraform {
  backend "s3" {
    bucket       = "my-terraform-state"
    key          = "terraform/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

module "vpc" {
  source = "./modules/VPC"

  availability_zone = "us-east-1a"
}

module "ec2" {
  source = "./modules/EC2"

  ami_id             = "ami-0abcdef1234567890"
  instance_type      = "t3.micro"
  subnet_id          = "subnet-12345678"
  security_group_ids = ["sg-12345678"]
  instance_name      = "terraform-ec2"
}