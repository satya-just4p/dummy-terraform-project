# Define the OIDC Provider. 
# The below code can be used if Identity Provider doesn't exists
#resource "aws_iam_openid_connect_provider" "github"{
#    url = "https://token.actions.githubusercontent.com"
#    clientid_list = ["sts.amazonaws.com"]
#    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1",
#    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"] # GitHub's root Cert
#}

# When the Identity Provider already exists
data "aws_iam_openid_connect_provider" "github"{
    url = "https://token.actions.githubusercontent.com"
}

# Create IAM Role for GitHub actions
resource "aws_iam_role" "github_actions_role"{
    name = "github-actions-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Principal = {
                Federated = data.aws_iam_openid_connect_provider.github.arn
            },
            Action = "sts:AssumeRoleWithWebIdentity",
            Condition = {
                stringEquals = {
                    "token.actions.githubusercontent.com:sub" = "repo:satya-just4p/dummy-terraform-project:ref:refs/heads/main"
                }
            }
        }]
    })
}

# Attach Inline Policies to the role
resource "aws_iam_role_policy" "cicid_user_inline_policy"{
    name = "cicd-user-inline-policy"
    role = aws_iam_role.github_actions_role.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
        Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket"

        ],
        Resource = [
            "arn:aws:s3::${var.angular_s3_bucket_name}",
            "arn:aws:s3::${var.angular_s3_bucket_name}/*"
        ]
        },
        {
            Effect = "Allow",
            Action = [
                "cloudfront:CreateInvalidation",
                "cloudfront:CreateInvalidationForDistributionTenant"
            ],
            Resource = ["*"]
        }
        
        ]
        
    })

}
 