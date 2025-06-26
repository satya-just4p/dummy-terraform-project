resource "aws_iam_role" "lambda_exec_role"{
    name = "dummy-lambda-exec-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = {
                Service = "lambda.amazonaws.com"
            }

        }]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role"{
    role = aws_iam_role.lambda_exec_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_rds_access"{
    role = aws_iam_role.lambda_exec_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access"{
    role = aws_iam_role.lambda_exec_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

#Security Group for Lambda to Access RDS sg
resource "aws_security_group" "lambda_dummy_sg"{
    vpc_id = aws_vpc.dummy_vpc.id
    name = "lambda-dummy-sg"

}

# Security Group Egress rule
 resource "aws_vpc_security_group_egress_rule" "lambda_db_access_egress"{
    security_group_id = aws_security_group.lambda_dummy_sg.id
    description = "Allows Lambda to Access RDS"
    from_port = 1433
    to_port = 1433
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.rds_dummy_sg.id
 }

 # Lambda function definition starts here

 resource "aws_lambda_function" "dummy_lambda_function"{
    function_name = "dummy-lambda-function"
     filename = "../DummyAPI/lamba_function_payload.zip"
     handler = "DummyAPI"
     runtime = "dotnet8"
     role = aws_iam_role.lambda_exec_role.arn
     memory_size = 1024
     timeout = 50

     vpc_config{
        subnet_ids = [aws_subnet.dummy_private_subnet.id]
        security_group_ids = [aws_security_group.lambda_dummy_sg.id]

     }

     environment{
        variables = {
            ASPNETCORE_ENVIRONMENT = "Development"
            DB_CONNECTION_STRING = "Server=${aws_db_instance.dummy_db_instance.address};Database=${var.db_name};User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=true"
            CORS_ALLOWED_ORIGINS = "https://${aws_cloudfront_distribution.angular_cdn.domain_name}"

        }
     }

     depends_on = [
        aws_iam_role_policy_attachment.lambda_basic_execution_role,
        aws_iam_role_policy_attachment.lambda_rds_access,
        aws_iam_role_policy_attachment.lambda_vpc_access
     ]
 }

 resource "aws_lambda_function_url" "dummy_lambda_function_url"{
    function_name = aws_lambda_function.dummy_lambda_function.function_name
    authorization_type = "NONE"

    cors{
        allow_origins = ["*"]
        allow_methods = ["*"]
        //allow_headers = ["content-type", "x-amz-date","authorization","x-api-key","x-amz-security-token"]
        allow_headers = ["*"]
        max_age = 300
    }
 }