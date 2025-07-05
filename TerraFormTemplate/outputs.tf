output "project_region"{
    description = "Project Region"
    value = var.aws_region
}
output "s3_bucket_name"{
    description = "S3 bucket Name"
    value = aws_s3_bucket.angular_bucket.bucket
}
output "angular_cloudfront_domain_name"{
    description = "Cloudfront domain name for Angular frontend"
    value = aws_cloudfront_distribution.angular_cdn.domain_name
}
output "angular_cloudfront_distribution_id"{
    description = "CloudFront Distribution Id"
    value = aws_cloudfront_distribution.angular_cdn.id
}
output "vpc_id"{
    description = "VPC ID for Dummy Project"
    value = aws_vpc.dummy_vpc.id
}
output "public_subnet_id"{
    description = "Public Subnet ID for Bastion Host"
    value = aws_subnet.dummy_public_subnet.id
}
output "private_subnet_id"{
    description = "Private Subnet ID for RDS and AWS Lambda"
    value = aws_subnet.dummy_private_subnet.id
}
output "bastion_dummy_sg_id"{
    description = "Security Group ID for Bastion Host"
    value = aws_security_group.bastion_dummy_sg.id
}
output "dummy_bastion_host_ip"{
    description = "Public IP of the Bastion Host for SSH Access"
    value = aws_instance.dummy_bastion_instance.public_ip
}

# output "bastion_ssh_command"{
#    description = "SSH command to connect to the Bastion Host"
#    value = "ssh -i ${tls_private_key.bastion_key.private_key_pem} ec2-user@${aws_instance.dummy_bastion_instance.public_ip}"
#    sensitive = true
#}

output "rds_endpoint"{
    description = "Amazon RDS endpoint for database connection"
    value = aws_db_instance.dummy_db_instance.endpoint
}

output "rds_address"{
    description = "Amazon RDS endpoint for database connection without the port"
    value = aws_db_instance.dummy_db_instance.address
}

output "lambda_function_name"{
    description = "AWS Lambda Function that deploys .Net API"
    value = aws_lambda_function.dummy_lambda_function.function_name
}
output "lambda_function_url"{
    description = "Lambda Function URL to check if Dot Net API is properly deployed"
    value = aws_lambda_function_url.dummy_lambda_function_url.function_url
    sensitive = false
}

output "angular_base_api_url"{
    description = "Base API URL for Angular app to call API gateway"
    value = aws_apigatewayv2_stage.dummy_stage.invoke_url
    sensitive = false
}

# Access Key and Secret Access Key output
output "cicd_user_access_key_id"{
    value = aws_iam_access_key.cicd_user_keys.id
    description = "Access key ID for CI/CD user"
    sensitive = true
}

output "cicd_user_secret_access_key"{
    value = aws_iam_access_key.cicd_user_keys.secret
    description = "Secret Access Key ID for CI/CD User"
    sensitive = true
}

#output "bastion_private_key"{
#    value = tls_private_key.bastion_key.private_key_pem
#    description = "EC2 bastion host RSA Private Key"
#    sensitive = true
#}