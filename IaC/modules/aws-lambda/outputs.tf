output "daily_lambda_bovespa_arn" {
  value = aws_lambda_function.daily_lambda_bovespa.arn
}

output "lambda_glue_activation_arn" {
  value = aws_lambda_function.lambda_glue_activation.arn
}