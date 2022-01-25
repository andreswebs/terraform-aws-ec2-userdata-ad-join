locals {
  ssm_param_ad_domain      = "${var.ad_ssm_prefix}${var.ad_ssm_parameter_name_domain}"
  ssm_param_ad_username    = "${var.ad_ssm_prefix}${var.ad_ssm_parameter_name_username}"
  ssm_param_ad_password    = "${var.ad_ssm_prefix}${var.ad_ssm_parameter_name_password}"
  ssm_param_ad_dns_servers = "${var.ad_ssm_prefix}${var.ad_ssm_parameter_name_dns_servers}"

  userdata = templatefile("${path.module}/tpl/userdata.tftpl", {
    log_group                = var.log_group
    log_retention_in_days    = var.log_retention_in_days
    ssm_param_ad_domain      = local.ssm_param_ad_domain
    ssm_param_ad_username    = local.ssm_param_ad_username
    ssm_param_ad_password    = local.ssm_param_ad_password
    ssm_param_ad_dns_servers = local.ssm_param_ad_dns_servers
  })
}
