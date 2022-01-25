data "aws_ami" "windows" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"]
}

module "ec2_role" {
  source       = "andreswebs/ec2-role/aws"
  version      = "1.0.0"
  role_name    = var.name
  profile_name = var.name
  policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
  ]
}

module "params_access" {
  source          = "andreswebs/ssm-parameters-access-policy-document/aws"
  version         = "1.0.0"
  parameter_names = [var.ad_ssm_prefix]
}

resource "aws_iam_role_policy" "params_access" {
  name   = "params-access"
  role   = module.ec2_role.role.name
  policy = module.params_access.json
}

#############################
## Use the module like this:
#############################
module "user_data" {
  source        = "github.com/andreswebs/terraform-aws-ec2-userdata-ad-join"
  ad_ssm_prefix = var.ad_ssm_prefix
}

resource "aws_instance" "windows" {
  ami                  = data.aws_ami.windows.id
  iam_instance_profile = module.ec2_role.instance_profile.name ## <-- Make sure the instance has proper permissions
  instance_type        = "t3a.xlarge"

  user_data_base64 = module.user_data.b64 ## <-- Use the module

  tags = {
    Name = "example-windows-server"
  }

  lifecycle {
    ignore_changes = [ami, tags]
  }

}