output "script" {
  value = local.userdata
}

output "b64" {
  value = base64encode(local.userdata)
}
