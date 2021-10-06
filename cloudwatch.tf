locals {
    fsx_name = lookup(var.tags, "Name", "Unkown name")
    
    warning_capacity_threshold = var.storage_capacity * 1000000000 * 0.10
    critical_capacity_threshold = var.storage_capacity * 1000000000 * 0.05

    throughput_threshold = var.throughput_capacity * 1000000 * 3 # Multiply in order to allow burst usage to take place before raising any alarms

    iops_threshold = var.storage_type == "SSD" ? var.storage_capacity * 3 : var.storage_capacity * 0.012 * 4 # 3000iops/TB for SSD or 12iops/TB for HDD
}

#
# Storage Capacity Metrics
#
resource "aws_cloudwatch_metric_alarm" "free_space_warning" {
  count               = var.cloudwatch_alarms_enabled == true ? 1 : 0

  alarm_name          = "${local.fsx_name} - free_space_warning_10_percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "FreeStorageCapacity"
  namespace           = "AWS/FSx"
  period              = "120"
  statistic           = "Average"
  threshold           = local.warning_capacity_threshold

  dimensions = {
    FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
  }

  alarm_description = "Warning - Less than 10% Free storage available on FSx filesystem"
  alarm_actions     = [var.sns_warning]
  ok_actions        = [var.sns_info]
  insufficient_data_actions = [var.sns_warning]
}

resource "aws_cloudwatch_metric_alarm" "free_space_critical" {
  count               = var.cloudwatch_alarms_enabled == true ? 1 : 0

  alarm_name          = "${local.fsx_name} - free_space_critical_5_percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "FreeStorageCapacity"
  namespace           = "AWS/FSx"
  period              = "120"
  statistic           = "Average"
  threshold           = local.critical_capacity_threshold

  dimensions = {
    FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
  }

  alarm_description = "CRITICAL - Less than 5% Free storage available on FSx filesystem"
  alarm_actions     = [var.sns_critical]
  ok_actions        = [var.sns_info]
  insufficient_data_actions = [var.sns_critical]
}

resource "aws_cloudwatch_metric_alarm" "free_space_immediate_action" {
  count               = var.cloudwatch_alarms_enabled == true ? 1 : 0

  alarm_name          = "${local.fsx_name} - free_space_critical_100GB - IMMEDIATE ACTION REQUIRED!!"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "FreeStorageCapacity"
  namespace           = "AWS/FSx"
  period              = "120"
  statistic           = "Average"
  threshold           = 100000000000

  dimensions = {
    FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
  }

  alarm_description = "IMMEDIATE ACTION REQUIRED - Less than 100GB Free storage available on FSx filesystem"
  alarm_actions     = [var.sns_critical]
  ok_actions        = [var.sns_info]
  insufficient_data_actions = [var.sns_critical]
}

#
# Throughput Metrics
#
resource "aws_cloudwatch_metric_alarm" "throughput_usage_warning" {
  count               = var.cloudwatch_alarms_enabled == true ? 1 : 0

  alarm_name          = "${local.fsx_name} - throughput_usage_warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  threshold           = local.throughput_threshold

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())/PERIOD(m1)"
    label       = "Total Throughput"
    return_data = "true"
  }

 metric_query {
    id = "m1"

    metric {
      metric_name = "DataReadBytes"
      namespace   = "AWS/FSx"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
      }
    }
  }
  
  metric_query {
    id = "m2"

    metric {
      metric_name = "DataWriteBytes"
      namespace   = "AWS/FSx"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
      }
    }
  }

  alarm_description = "WARNING - Throughput Usage over specification on FSx filesystem - Consuming burst credits"
  alarm_actions     = [var.sns_warning]
  ok_actions        = [var.sns_info]
  insufficient_data_actions = [var.sns_warning]
}

resource "aws_cloudwatch_metric_alarm" "throughput_usage_critical" {
  count               = var.cloudwatch_alarms_enabled == true ? 1 : 0

  alarm_name          = "${local.fsx_name} - throughput_usage_critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "15"
  datapoints_to_alarm = "10"
  threshold           = local.throughput_threshold

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())/PERIOD(m1)"
    label       = "Total Throughput"
    return_data = "true"
  }

 metric_query {
    id = "m1"

    metric {
      metric_name = "DataReadBytes"
      namespace   = "AWS/FSx"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
      }
    }
  }
  
  metric_query {
    id = "m2"

    metric {
      metric_name = "DataWriteBytes"
      namespace   = "AWS/FSx"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
      }
    }
  }

  alarm_description = "CRITICAL - Sustained throughput Usage over specification on FSx filesystem - burst credit will be depleating"
  alarm_actions     = [var.sns_critical]
  ok_actions        = [var.sns_info]
  insufficient_data_actions = [var.sns_critical]
}

#
# IOPS Metrics
#
resource "aws_cloudwatch_metric_alarm" "iops_warning" {
  count               = var.cloudwatch_alarms_enabled == true ? 1 : 0

  alarm_name          = "${local.fsx_name} - iops_warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "10"
  threshold           = local.iops_threshold

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())/PERIOD(m1)"
    label       = "Total IOPS"
    return_data = "true"
  }

 metric_query {
    id = "m1"

    metric {
      metric_name = "DataReadOperations"
      namespace   = "AWS/FSx"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
      }
    }
  }
  
  metric_query {
    id = "m2"

    metric {
      metric_name = "DataWriteOperations"
      namespace   = "AWS/FSx"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
      }
    }
  }  

  metric_query {
    id = "m3"

    metric {
      metric_name = "MetadataOperations"
      namespace   = "AWS/FSx"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
      }
    }
  }

  alarm_description = "WARNING - IOPS Usage over specification on FSx filesystem - Consuming burst credits"
  alarm_actions     = [var.sns_warning]
  ok_actions        = [var.sns_info]
  insufficient_data_actions = [var.sns_warning]
}

resource "aws_cloudwatch_metric_alarm" "iops_critical" {
  count               = var.cloudwatch_alarms_enabled == true ? 1 : 0

  alarm_name          = "${local.fsx_name} - iops_critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "30"
  datapoints_to_alarm = "20"
  threshold           = local.iops_threshold

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())/PERIOD(m1)"
    label       = "Total IOPS"
    return_data = "true"
  }

 metric_query {
    id = "m1"

    metric {
      metric_name = "DataReadOperations"
      namespace   = "AWS/FSx"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
      }
    }
  }
  
  metric_query {
    id = "m2"

    metric {
      metric_name = "DataWriteOperations"
      namespace   = "AWS/FSx"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
      }
    }
  }  

  metric_query {
    id = "m3"

    metric {
      metric_name = "MetadataOperations"
      namespace   = "AWS/FSx"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, tolist([""])),0)
      }
    }
  }

  alarm_description = "CRITICAL - Sustained IOPS Usage over specification on FSx filesystem - burst credit will be depleating"
  alarm_actions     = [var.sns_critical]
  ok_actions        = [var.sns_info]
  insufficient_data_actions = [var.sns_critical]
}