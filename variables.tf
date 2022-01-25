variable "log_group" {
  type        = string
  description = "Name of the log group to log user-data output"
  default     = "/windows"
}

variable "log_retention_in_days" {
  type        = number
  description = "Log retention in days"
  default     = 30
}

variable "ad_ssm_prefix" {
  type        = string
  description = "SSM parameter prefix for AD configurations"
  default     = "/ad"
}

variable "ad_ssm_parameter_name_domain" {
  type        = string
  description = "Name suffix of the SSM parameter containing the AD domain name"
  default     = "/domain"
}

variable "ad_ssm_parameter_name_username" {
  type        = string
  description = "Name suffix of the SSM parameter containing the AD username"
  default     = "/username"
}

variable "ad_ssm_parameter_name_password" {
  type        = string
  description = "Name suffix of the SSM parameter containing the AD password"
  default     = "/password"
}

variable "ad_ssm_parameter_name_dns_servers" {
  type        = string
  description = "Name suffix of the SSM parameter containing the AD domain controller IPs (DNS servers)"
  default     = "/dns-servers"
}

