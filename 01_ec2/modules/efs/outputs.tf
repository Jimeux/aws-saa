output "file_system_id" {
  value = aws_efs_file_system.app_server_efs.id
}

output "security_group_id" {
  value = aws_security_group.efs.id
}
