terraform{
    backend "s3"{
        bucket = "dummy-tfstate-bucket"
        key = "terraform.tfstate"
        region = "eu-central-1"
        dynamodb_table = "tfstate-lock-table"
    }
}