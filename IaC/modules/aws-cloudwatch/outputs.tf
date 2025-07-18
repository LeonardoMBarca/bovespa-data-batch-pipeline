output "cloudwatch_event_rule_arn" {
  value = aws_cloudwatch_event_rule.bovespa_event.arn
}

output "cloudwatch_event_rule_name" {
  value = aws_cloudwatch_event_rule.bovespa_event.name
}

output "event_bitcoin_arn" {
  value = aws_cloudwatch_event_rule.bitcoin_backup.arn
}