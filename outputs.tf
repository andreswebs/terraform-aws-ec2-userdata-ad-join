output "script" {
  description = "The user-data script"
  value       = local.userdata
}

output "b64" {
  description = "Base64-encoded user-data script"
  value       = base64encode(local.userdata)
}
