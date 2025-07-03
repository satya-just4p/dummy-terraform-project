variable "bucket_name"{
    description = "Name of the S3 bucket for storing the terraform state"
    type = string 
}

variable "lock_table_name"{
    description = "Name of the DynamoDB Table name for State locking "
    type = string
}

variable "environment"{
    description = "Deployment Environment (eg.dev, test, prod)"
    type = string
    default = "dev"
}