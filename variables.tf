variable "create_filesystem" {
  description = "Controls if FSx should be created"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The AWS KMS master key ID used for encryption."
  type        = string
  default     = null

variable "storage_type" {
  description = "Specifies the storage type, Valid values are SSD and HDD. HDD is supported on SINGLE_AZ_1 and MULTI_AZ_1 Windows file system deployment types. Default value is SSD."
  type        = string
  default     = "SSD"
}

variable "storage_capacity" {
  description = "Storage capacity (GiB) of the file system. Minimum of 32 and maximum of 65536. If the storage type is set to HDD the minimum value is 2000."
  type        = string
  default     = "32"
}

variable "throughput_capacity" {
  description = "Throughput (megabytes per second) of the file system in power of 2 increments. Minimum of 8 and maximum of 2048."
  type        = string
  default     = "8"
}


variable "subnet_ids" {
  description = "A list of IDs for the subnets that the file system will be accessible from. To specify more than a single subnet set deployment_type to MULTI_AZ_1."
  type        = any # should be `map`, but it produces an error "all map elements must have the same type"
  default     = []
}

variable "automatic_backup_retention_days" {
  description = "The number of days to retain automatic backups. Minimum of 0 and maximum of 35. Defaults to 7. Set to 0 to disable."
  type        = string
  default     = 28
}

variable "copy_tags_to_backups" {
  description = "A boolean flag indicating whether tags on the file system should be copied to backups. Defaults to false."
  type        = bool
  default     = true
}

variable "daily_automatic_backup_start_time" {
  description = "The preferred time (in HH:MM format) to take daily automatic backups, in the UTC time zone."
  type        = string
  default     = "00:00"
}

variable "weekly_maintenance_start_time" {
  description = "The preferred start time (in d:HH:MM format) to perform weekly maintenance, in the UTC time zone."
  type        = string
  default     = "7:05:00"
}

variable "security_group_ids" {
  description = "A list of IDs for the security groups that apply to the specified network interfaces created for file system access. These security groups will apply to all network interfaces."
  type        = any
  default     = []
}

variable "skip_final_backup" {
  description = "When enabled, will skip the default final backup taken when the file system is deleted. This configuration must be applied separately before attempting to delete the resource to have the desired behavior. Defaults to false."
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "deployment_type" {
  description = "Specifies the file system deployment type, valid values are MULTI_AZ_1 and SINGLE_AZ_1. Default value is SINGLE_AZ_1."
  type        = string
  default     = "MULTI_AZ_1"
}

variable "preferred_subnet_id" {
  description = " Specifies the subnet in which you want the preferred file server to be located. Required for when deployment type is MULTI_AZ_1."
  type        = string
  default     = null
}

variable "active_directory_enabled" {
  description = "Controls if FSx uses the Active Directory Configuration"
  type        = bool
  default     = true
}

variable "dns_ips" {
  description = "A list of up to two IP addresses of DNS servers or domain controllers in the self-managed AD directory. The IP addresses need to be either in the same VPC CIDR range as the file system or in the private IP version 4 (IPv4) address ranges as specified in RFC 1918."
  type        = any
  default     = null
}

variable "domain_name" {
  description = "The fully qualified domain name of the self-managed AD directory. For example, corp.example.com."
  type        = string
  default     = null
}

variable "password" {
  description = "The password for the service account on your self-managed AD domain that Amazon FSx will use to join to your AD domain."
  type        = string
  default     = null
}

variable "username" {
  description = "The user name for the service account on your self-managed AD domain that Amazon FSx will use to join to your AD domain."
  type        = string
  default     = null
}

variable "file_system_administrators_group" {
  description = "The name of the domain group whose members are granted administrative privileges for the file system. Administrative privileges include taking ownership of files and folders, and setting audit controls (audit ACLs) on files and folders. The group that you specify must already exist in your domain. Defaults to Domain Admins."
  type        = string
  default     = "Domain Admins"
}

variable "organizational_unit_distinguished_name" {
  description = "The fully qualified distinguished name of the organizational unit within your self-managed AD directory that the Windows File Server instance will join. For example, OU=FSx,DC=yourdomain,DC=corp,DC=com. Only accepts OU as the direct parent of the file system. If none is provided, the FSx file system is created in the default location of your self-managed AD directory. To learn more, see RFC 2253."
  type        = string
  default     = null
}