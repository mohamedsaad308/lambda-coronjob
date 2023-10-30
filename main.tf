
provider "aws" {
  region     = "eu-west-3"
}



variable "lambda_filename" {}




resource "aws_lambda_function" "my_lambda" {
  function_name = "MyLambdaFunction"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  filename = var.lambda_filename
  role = aws_iam_role.lambda_role.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "MyLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name = "MyLambdaSchedule"
  description = "Schedule for running the Lambda function"
  schedule_expression = "cron(0 3 * * ? *)" # Runs every day at 3:00 AM UTC

}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.lambda_schedule.name
  arn  = aws_lambda_function.my_lambda.arn
}


resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}


output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda.arn
}
