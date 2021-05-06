# AWS FSx for Windows File Server Terraform module

Terraform module which creates FSx resources on AWS.

This module focuses on EC2 Instance, EBS Volumes and EBS Volume Attachments.

* [FSx Windows File System](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_windows_file_system)
* [Cloudwatch Metric Alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)

This Terraform module will provide the required resources for an FSx FilesServer and all the required resources.

## Terraform versions

Terraform ~> 0.12

## Usage

FSx Windows File Server Example with minimum required and useful settings options
```hcl
module "fsx" {
  storage_type        = "SSD"
  storage_capacity    = "1000"
  throughput_capacity = "16"
  copy_tags_to_backups = true 
  subnet_ids           = [local.priv_a, local.priv_b]
  preferred_subnet_id  = local.priv_a

  kms_key_id         = "[kms_id]"

  security_group_ids = [aws_security_group.fsx.id]
  
  dns_ips                                = ["1.1.1.1", "2.2.2.2"]
  domain_name                            = "example.corp"
  password                               = "secretpassword"
  username                               = "svc_account"
  file_system_administrators_group       = "MyFSxAdmins"
  organizational_unit_distinguished_name = "OU=FSx,OU=Servers,DC=example,DC=corp"

  tags = merge(
    local.common_tags,
    {
      "Name"                 = "fsx_example"
      "Description"          = "FSx File system for the following shares - User Profiles"
      "CreationDate"         = "2020-01-01"
      "Quadrant"             = "Q2"
      "CostCentre"           = "ABCDEFG"
    },
  )

  sns_critical = "[sns_topic_arn]"
  sns_warning  = "[sns_topic_arn]"
  sns_info     = "[sns_topic_arn]"
}
```

## Conditional creation

Sometimes you need to have a way to create FSx resources conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `create_filesystem`.

```hcl
# FSx will not be created
module "fsx" {
  source  = "github.com/affinitywaterltd/terraform-aws-fsx_windows_file_system"

  create_filesystem = false
  # ... omitted
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_filesystem  | Controls if FSx should be created | `bool` | `true` | no |
| storage_type | Specifies the storage type, Valid values are SSD and HDD. HDD is supported on SINGLE_AZ_1 and MULTI_AZ_1 Windows file system deployment types. Default value is SSD. | `string` | `"SSD"` | yes |
| storage_capacity | Storage capacity (GiB) of the file system. Minimum of 32 and maximum of 65536. If the storage type is set to HDD the minimum value is 2000 | `string` | `32` | no |
| throughput_capacity | Throughput (megabytes per second) of the file system in power of 2 increments. Minimum of 8 and maximum of 2048. | `string` | `8` | no |
| deployment_type | Specifies the file system deployment type, valid values are MULTI_AZ_1 and SINGLE_AZ_1. Default value is SINGLE_AZ_1. | `string` | `MULTI_AZ_1` | no |
| subnet_ids | A list of IDs for the subnets that the file system will be accessible from. To specify more than a single subnet set deployment_type to MULTI_AZ_1 | `any` | []` | yes |
| preferred_subnet_id | Specifies the subnet in which you want the preferred file server to be located. Required for when deployment type is MULTI_AZ_1 | `string` | `null` | no |
| availability_zone | Availability Zone the instance is launched in. If not set, will be launched in the first AZ of the region | `string` | `none` | yes |
| security_group_ids | A list of IDs for the security groups that apply to the specified network interfaces created for file system access. These security groups will apply to all network interfaces | `any` | `[]` | no |
| active_directory_enabled | Enable EC2 Instance Termination Protectio | `bool` | `true` | no |
| dns_ips | A list of up to two IP addresses of DNS servers or domain controllers in the self-managed AD directory. The IP addresses need to be either in the same VPC CIDR range as the file system or in the private IP version 4 (IPv4) address ranges as specified in RFC 1918. | `any` | `null` | no |
| domain_name | The fully qualified domain name of the self-managed AD directory. For example, corp.example.com | `string` | `null` | no |
| password | The password for the service account on your self-managed AD domain that Amazon FSx will use to join to your AD domain | `string` | `null` | no |
| username | The user name for the service account on your self-managed AD domain that Amazon FSx will use to join to your AD domain | `string` | `null` | no |
| file_system_administrators_group | The name of the domain group whose members are granted administrative privileges for the file system. Administrative privileges include taking ownership of files and folders, and setting audit controls (audit ACLs) on files and folders. The group that you specify must already exist in your domain. Defaults to Domain Admins | `string` | `Domain Admins` | no |
| organizational_unit_distinguished_name | The fully qualified distinguished name of the organizational unit within your self-managed AD directory that the Windows File Server instance will join. For example, OU=FSx,DC=yourdomain,DC=corp,DC=com. Only accepts OU as the direct parent of the file system. If none is provided, the FSx file system is created in the default location of your self-managed AD directory. To learn more, see RFC 2253 | `string` | `null` | no |
| cloudwatch_alarms_enabled | Controls if FSx is monitored using CloudWatch alarms | `bool` | `true` | no |
| sns_critical | SNS topic ARN for critical alerts | `string` | `null` | no |
| sns_warning | SNS topic ARN for warning alerts | `string` | `null` | no |
| sns_info | SNS topic ARN for info alerts | `string` | `null` | no |
| skip_final_backup | When enabled, will skip the default final backup taken when the file system is deleted. This configuration must be applied separately before attempting to delete the resource to have the desired behaviour. Defaults to false | `bool` | `false` | no |
| automatic_backup_retention_days | The number of days to retain automatic backups. Minimum of 0 and maximum of 35. Defaults to 7. Set to 0 to disable. | `string` | `20` | no |
| copy_tags_to_backups | A boolean flag indicating whether tags on the file system should be copied to backups. Defaults to false. | `bool` | `true` | no |
| daily_automatic_backup_start_time | The preferred time (in HH:MM format) to take daily automatic backups, in the UTC time zone | `string` | `00:00` | no |
| weekly_maintenance_start_time | The preferred start time (in d:HH:MM format) to perform weekly maintenance, in the UTC time zone | `string` | `7:05:00` | no |
| kms_key_id | The AWS KMS master key ID used for encryption | `string` | `null` | no |
| tags | A mapping of tags to assign to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Identifier of the file system |
| arn | Amazon Resource Name of the file system |
| dns_name | DNS name for the file system, e.g. fs-12345678.corp.example.com (domain name matching the Active Directory domain name) |
| preferred_file_server_ip | The IP address of the primary, or preferred, file server |
| remote_administration_endpoint | For MULTI_AZ_1 deployment types, use this endpoint when performing administrative tasks on the file system using Amazon FSx Remote PowerShell. For SINGLE_AZ_1 deployment types, this is the DNS name of the file system. |