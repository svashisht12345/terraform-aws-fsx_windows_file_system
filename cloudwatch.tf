locals {
    warning_capacity_threshold = var.storage_capacity * 1000000 * 0.15
}

resource "aws_cloudwatch_metric_alarm" "free_space_warning" {
  alarm_name          = "free_space_warning_15_percent"
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