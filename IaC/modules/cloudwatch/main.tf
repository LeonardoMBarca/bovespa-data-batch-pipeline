resource "aws_cloudwatch_event_rule" "bovespa_event" {
  name = "daily-event-bovespa"

  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "bovespa_lambda_target" {
  rule      = aws_cloudwatch_event_rule.bovespa_event.name
  target_id = "bovespa_lambda_target"
  arn       = var.daily_lambda_bovespa_arn
}
