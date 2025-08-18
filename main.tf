data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

#pull in default values
data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.blog_sg.security_group_id]

  tags = {
    Name = "Learning Terraform"
  }
}

module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  name = "blog_new"
  vpc_id      = data.aws_vpc.default.id

  ingress_rules = ["https-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}




#security group
resource "aws_security_group" "blog" {
  name        = "blog" #name that will show up in AWS console, otherwise randomly assigned
  description = "Allow http and https in. Allow everything out"

  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "blog_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_everything_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1" #allow all protocol
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}