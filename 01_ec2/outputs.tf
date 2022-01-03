output "ebs_only_ip" {
  value = module.ebs_only_instance.public_ip
}

output "instance_store_ip" {
  value = module.instance_store_instance.public_ip
}

output "efs_file_system_id" {
  value = module.shared_efs.file_system_id
}
