locals {
    self_managed_active_directory_config = {
        dns_ips                                = var.dns_ips
        domain_name                            = var.domain_name
        password                               = var.password
        username                               = var.username
        file_system_administrators_group       = var.file_system_administrators_group
        organizational_unit_distinguished_name = var.organizational_unit_distinguished_name

    }
}


resource "aws_fsx_windows_file_system" "default" {
  count               = var.create_filesystem == true ? 1 : 0
  kms_key_id          = var.kms_key_id

  storage_type        = var.storage_type
  storage_capacity    = var.storage_capacity
  throughput_capacity = var.throughput_capacity
  subnet_ids          = var.subnet_ids
  preferred_subnet_id = var.preferred_subnet_id

  automatic_backup_retention_days   = var.automatic_backup_retention_days
  copy_tags_to_backups              = var.copy_tags_to_backups
  daily_automatic_backup_start_time = var.daily_automatic_backup_start_time

  security_group_ids = var.security_group_ids
  weekly_maintenance_start_time = var.weekly_maintenance_start_time

  deployment_type = var.deployment_type

  dynamic "self_managed_active_directory" {
    for_each = var.active_directory_enabled == true ? [local.self_managed_active_directory_config] : []

    content {
      dns_ips                                = lookup(local.self_managed_active_directory_config, "dns_ips", [])
      domain_name                            = lookup(local.self_managed_active_directory_config, "domain_name", null)
      password                               = lookup(local.self_managed_active_directory_config, "password", null)
      username                               = lookup(local.self_managed_active_directory_config, "username", null)
      file_system_administrators_group       = lookup(local.self_managed_active_directory_config, "file_system_administrators_group", null)
      organizational_unit_distinguished_name = lookup(local.self_managed_active_directory_config, "organizational_unit_distinguished_name", null)
    }
  }

  tags = var.tags


  lifecycle { # Required due to no APIs to read security groups so will always moan about imported FSx SGs
    ignore_changes = [security_group_ids]
  }
}