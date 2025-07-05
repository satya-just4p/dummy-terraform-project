# IAM User Inline Policy Creation allowing Github to access S3 and CloudFront
resource "aws_iam_policy" "cicd_angular_policy"{
    name = "CI_CD_Angular_S3_CloudFront_Policy"
    description = "Policy for GitHub Actions to access S3 and CloudFront"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Action = [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            Resource = [
                "arn:aws:s3:::${var.angular_s3_bucket_name}",
                "arn:aws:s3:::${var.angular_s3_bucket_name}/*"
            ]
        },
        {
            Effect = "Allow",
            Action = [
                "cloudfront:CreateInvalidation",
                "cloudfront:CreateInvalidationForDistributionTenant"
            ],
            Resource = "*"
        }
        ]
    })
}

# IAM User creation to allow GitHub access S3 and CloudFront

resource "aws_iam_user" "cicd_user"{
    name = var.cicd_user_name
   
}

# Attaching Policy to the created IAM User

resource "aws_iam_user_policy_attachment" "cicd_attach_policy"{
    user = aws_iam_user.cicd_user.name
    policy_arn = aws_iam_policy.cicd_angular_policy.arn
}

# Creating Access Keys for GitHub Secrets to access S3 and CloudFront

resource "aws_iam_access_key" "cicd_user_keys"{
    user = aws_iam_user.cicd_user.name

}