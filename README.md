# terraform-aws-ec2-userdata-ad-join

Generates a user-data script for dynamically joining and un-joining Windows EC2 instances to an Active Directory domain.

## Configuration

The user-data script will fetch configuration values from SSM parameters. These parameters are assumed to already exist in the environment.

Default parameter names used by the module are:

- `/ad/domain`
- `/ad/username`
- `/ad/password`
- `/ad/dns-servers`

The parameter names are configured from Terraform variables. (See the input values below.)

The "username" and "password" parameters must contain credentials from an AD user with enough permissions to join machines to the domain.

## IAM permissions

The user-data script assumes that the EC2 instance role has the proper permissions to access these parameters.

The following IAM policy is an example that can be adapted and added to the instance role to accomplish that.
Replace `${AWS_REGION}` and `${AWS_ACCOUNT_ID}` with the correct values for the environment. 

This example assumes that the parameter prefix for AD configurations is `/ad`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath",
        "ssm:GetParameterHistory"
      ],
      "Resource": "arn:aws:ssm:${AWS_REGION}:${AWS_ACCOUNT_ID}:parameter/ad/*"
    }
  ]
}
```

[//]: # (BEGIN_TF_DOCS)


## Usage

Example:

```hcl
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
```



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ad_ssm_parameter_name_dns_servers"></a> [ad\_ssm\_parameter\_name\_dns\_servers](#input\_ad\_ssm\_parameter\_name\_dns\_servers) | Name suffix of the SSM parameter containing the AD domain controller IPs (DNS servers) | `string` | `"/dns-servers"` | no |
| <a name="input_ad_ssm_parameter_name_domain"></a> [ad\_ssm\_parameter\_name\_domain](#input\_ad\_ssm\_parameter\_name\_domain) | Name suffix of the SSM parameter containing the AD domain name | `string` | `"/domain"` | no |
| <a name="input_ad_ssm_parameter_name_password"></a> [ad\_ssm\_parameter\_name\_password](#input\_ad\_ssm\_parameter\_name\_password) | Name suffix of the SSM parameter containing the AD password | `string` | `"/password"` | no |
| <a name="input_ad_ssm_parameter_name_username"></a> [ad\_ssm\_parameter\_name\_username](#input\_ad\_ssm\_parameter\_name\_username) | Name suffix of the SSM parameter containing the AD username | `string` | `"/username"` | no |
| <a name="input_ad_ssm_prefix"></a> [ad\_ssm\_prefix](#input\_ad\_ssm\_prefix) | SSM parameter prefix for AD configurations | `string` | `"/ad"` | no |
| <a name="input_log_group"></a> [log\_group](#input\_log\_group) | Name of the log group to log user-data output | `string` | `"/windows"` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | Log retention in days | `number` | `30` | no |

## Modules

No modules.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_b64"></a> [b64](#output\_b64) | n/a |
| <a name="output_script"></a> [script](#output\_script) | n/a |

## Providers

No providers.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |

## Resources

No resources.

[//]: # (END_TF_DOCS)

## Authors

**Andre Silva** - [@andreswebs](https://github.com/andreswebs)

## License

This project is licensed under the [Unlicense](UNLICENSE.md).

## References

<https://aws.amazon.com/blogs/compute/managing-domain-membership-of-dynamic-fleet-of-ec2-instances/>
