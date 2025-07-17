output "daily_lambda_bovespa_role_name" {
  value = var.create_new_role_daily_lambda_bovespa ? aws_iam_role.daily_lambda_bovespa_role[0].name : ""
}

output "lambda_glue_activation_role_name" {
  value = var.create_new_role_lambda_glue_activation ? aws_iam_role.lambda_glue_activation_role[0].name : ""
}

output "glue_job_role_name" {
  value = var.create_new_role_glue_job ? aws_iam_role.glue_job_role[0].name : ""
}

output "instance_profile_name" {
  value = var.create_new_ec2_profile_role ? aws_iam_instance_profile.instance_profile[0].name : ""

}