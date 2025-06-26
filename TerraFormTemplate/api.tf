# API Gateway definition
resource "aws_apigatewayv2_api" "dummy_http_api"{
    name = "dummy-http-api"
    protocol_type = "HTTP"
}

# API Gateway Integration with AWS Lambda
resource "aws_apigatewayv2_integration" "dummy_integration"{
    api_id = aws_apigatewayv2_api.dummy_http_api.id
    integration_type = "AWS_PROXY"
    integration_uri = aws_lambda_function.dummy_lambda_function.invoke_arn
    integration_method = "POST"
    payload_format_version = "2.0"
}

# API Gateway route
resource "aws_apigatewayv2_route" "dummy_route"{
    api_id = aws_apigatewayv2_api.dummy_http_api.id
    route_key = "ANY /{proxy+}"
    target = "integrations/${aws_apigatewayv2_integration.dummy_integration.id}"
}

# Permission for API Gateway to call AWS Lambda
resource "aws_lambda_permission" "dummy_lambda_permission"{
    statement_id = "AllowAPIGatewayToInvokeLambdaFunction"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.dummy_lambda_function.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.dummy_http_api.execution_arn}/*/*"
}

# Deployment Stage of the API Gateway
resource "aws_apigatewayv2_stage" "dummy_stage"{
    api_id = aws_apigatewayv2_api.dummy_http_api.id
    name = "$default"
    auto_deploy = true
}