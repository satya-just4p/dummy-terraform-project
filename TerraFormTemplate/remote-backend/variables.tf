variable "bucket_name"{
    description = "Name of the S3 bucket for storing the terraform state"
    default = "dummy-tfstate-bucket"
    type = string 
}

variable "lock_table_name"{
    description = "Name of the DynamoDB Table name for State locking "
    type = string
    default = "tfstate-lock-table"
}

variable "environment"{
    description = "Deployment Environment (eg.dev, test, prod)"
    type = string
    default = "dev"
}