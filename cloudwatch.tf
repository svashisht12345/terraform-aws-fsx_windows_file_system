locals {
    warning_capacity_threshold = var.storage_capacity * 1000000000 * 0.15
    critical_capacity_threshold = var.storage_capacity * 1000000000 * 0.10

    
    critical_throughput_threshold = (var.throughput_capacity * 1000000) * 0.90
    fsx_name = lookup(var.tags, "Name", "Unkown name")
}

resource "aws_cloudwatch_metric_alarm" "free_space_warning" {
  alarm_name          = "${local.fsx_name} - free_space_warning_15_percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "FreeStorageCapacity"
  namespace           = "AWS/FSx"
  period              = "120"
  statistic           = "Average"
  threshold           = local.warning_capacity_threshold

  dimensions = {
    FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, list("")),0)
  }

  alarm_description = "Warning - Less than 15% Free storage available on FSx filesystem"
  alarm_actions     = [var.sns_warning]
  ok_actions        = [var.sns_info]
  insufficient_data_actions = [var.sns_warning]
}


resource "aws_cloudwatch_metric_alarm" "free_space_critical" {
  alarm_name          = "${local.fsx_name} - free_space_critical_10_percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "FreeStorageCapacity"
  namespace           = "AWS/FSx"
  period              = "120"
  statistic           = "Average"
  threshold           = local.critical_capacity_threshold

  dimensions = {
    FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, list("")),0)
  }

  alarm_description = "CRITICAL - Less than 10% Free storage available on FSx filesystem"
  alarm_actions     = [var.sns_critical]
  ok_actions        = [var.sns_warning]
  insufficient_data_actions = [var.sns_critical]
}



resource "aws_cloudwatch_metric_alarm" "throughput_usage_critical" {
  alarm_name          = "${local.fsx_name} - throughput_usage_critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  threshold           = local.critical_capacity_threshold

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
      unit        = "Bytes/Second"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, list("")),0)
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
      unit        = "Bytes/Second"

      dimensions = {
        FileSystemId = element(concat(aws_fsx_windows_file_system.default.*.id, list("")),0)
      }
    }
  }

  alarm_description = "CRITICAL - Throughput Usage over 90% on FSx filesystem"
  alarm_actions     = [var.sns_critical]
  ok_actions        = [var.sns_warning]
  insufficient_data_actions = [var.sns_critical]
}