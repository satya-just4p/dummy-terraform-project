variable "aws_region"{
    default = "eu-central-1"
}

variable "angular_s3_bucket_name"{
    description = "S3 bucketname to host Angular app"
    type = string
    default = "dummyprojectbucket.1981"
}

variable "vpc_cidr"{
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr"{
    default = "10.0.1.0/24"
}

variable "private_subnet_cidr"{
    default = "10.0.2.0/24"
}
variable "private_subnet_cidr_b"{
    default = "10.0.3.0/24"
}

variable "key_pair_name"{
    default = "dummy-bastion-key"
}
variable "public_key_path"{
    default = "../SSH/dummy-bastion-key.pub"
}

variable "db_username"{
    default = "dummy"
}
variable "db_password"{
    default = "dummydb_2025"
}
variable "db_name"{
    default = "dummydb"
}