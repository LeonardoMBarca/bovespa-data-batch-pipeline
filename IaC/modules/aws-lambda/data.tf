data "archive_file" "lambda_glue_activation_scripts" {
  type        = "zip"
  source_dir  = "${path.module}/../../scripts/lambda-scripts/lambda-glue-activation"
  output_path = "${path.module}/../../scripts/lambda-scripts/lambda-glue-activation.zip"
}