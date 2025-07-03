resource "aws_s3_bucket" "tf_state_bucket"{
    bucket = var.bucket_name

    lifecycle{
        prevent_destroy = true
    }

    force_destroy = true

    tags = {
        Name = "terraform State Bucket"
        Environment = var.environment
    }
}

# S3 Bucket Versioning
# resource "aws_s3_bucket_versioning" "versioning"{
#     bucket = aws_s3_bucket.tf_state_bucket.id
#       versioning_configuration{
#         status = "Enabled"
#       }
# }

# DynamoDB Table creation for Terraform state
# Default Billing mode is provisioned
# read_capacity must be at least 1 when billing_mode is "PROVISIONED"
# write_capacity must be at least 1 when billing_mode is "PROVISIONED"

resource "aws_dynamodb_table" "tf_lock_table"{
    name = var.lock_table_name
    billing_mode = "PAY_PER_REQUEST"


    lifecycle{
        prevent_destroy = true
    }

    hash_key = "LockID"

    attribute{
        name = "LockID"
        type = "S"
    }

    tags={
        Name = "Terraform Lock Table"
        Environment = var.environment
    }

}