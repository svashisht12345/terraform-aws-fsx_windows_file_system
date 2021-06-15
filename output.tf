output "id" {
  description = "Identifier of the file system"
  value       = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
}

output "arn" {
  description = "Amazon Resource Name of the file system."
  value       = element(concat(aws_fsx_windows_file_system.default.*.arn, tolist([""])),0)
}

output "dns_name" {
  description = "DNS name for the file system, e.g. fs-12345678.corp.example.com (domain name matching the Active Directory domain name)"
  value       = element(concat(aws_fsx_windows_file_system.default.*.dns_name, tolist([""])),0)
}

output "preferred_file_server_ip" {
  description = "The IP address of the primary, or preferred, file server."
  value       = element(concat(aws_fsx_windows_file_system.default.*.preferred_file_server_ip, tolist([""])),0)
}

output "remote_administration_endpoint" {
  description = "For MULTI_AZ_1 deployment types, use this endpoint when performing administrative tasks on the file system using Amazon FSx Remote PowerShell. For SINGLE_AZ_1 deployment types, this is the DNS name of the file system."
  value       = element(concat(aws_fsx_windows_file_system.default.*.remote_administration_endpoint, tolist([""])),0)
}