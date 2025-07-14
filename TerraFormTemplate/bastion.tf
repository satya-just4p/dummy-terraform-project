resource "aws_security_group" "bastion_dummy_sg"{
    name = "bastion-dummy-sg"
    description = "Allow SSH into RDS from my IP"
    vpc_id = aws_vpc.dummy_vpc.id

     tags = {
        Name = "dummy-bastion-sg"
    }
       
}
resource "aws_vpc_security_group_ingress_rule" "ssh_access_from_my_ip"{
    security_group_id = aws_security_group.bastion_dummy_sg.id
    description = "SSH from my IP"

    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr_ipv4 = "91.42.30.197/32"
      
}

# RDP Access from my IP
resource "aws_vpc_security_group_ingress_rule" "rdp_access_from_my_ip"{
    security_group_id = aws_security_group.bastion_dummy_sg.id
    description = "Allows RDP access from my IP"

    from_port = 3389
    to_port = 3389
    ip_protocol = "tcp"
    cidr_ipv4 = "91.42.30.197/32"
}

resource "aws_vpc_security_group_egress_rule" "bastion_internet_access"{
    description = "Allows Internet Access for Bastion"
    security_group_id = aws_security_group.bastion_dummy_sg.id

    from_port = 0
    to_port = 0
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
    
}

resource "aws_vpc_security_group_egress_rule" "bastion_rds_access"{
    security_group_id = aws_security_group.bastion_dummy_sg.id
    description = "Allows Bastion to access RDS"

    from_port = 1433
    to_port = 1433
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.rds_dummy_sg.id
}

# RSA Key Pair generation starts here:
resource "tls_private_key" "bastion_key"{
    algorithm = "RSA"
    rsa_bits = 4096 
}

resource "aws_key_pair" "bastion_keypair"{
    key_name = var.key_pair_name
    public_key = tls_private_key.bastion_key.public_key_openssh
}

# This Code Block stores the .pem private key onto the local drive
# This code block can be used when testing locally
# resource "local_file" "private_key_pem"{
# content = tls_private_key.bastion_key.private_key_pem
# filename = "${path.module}/../SSH/dummy-bastion-key.pem"
# file_permission = "0400"
# }

# Below code block saves the private bastion key to the S3 bucket

resource "aws_s3_bucket" "secure_key_bucket"{
bucket = var.bastion_private_key
force_destroy = true


tags={
    Name = "bastion-private-key-storage"
}
}

# S3 bucket Ownership
resource "aws_s3_bucket_ownership_controls" "bastion_object_ownership"{
bucket = aws_s3_bucket.secure_key_bucket.id
    rule{
            object_ownership = "BucketOwnerEnforced"

    }

    depends_on = [aws_s3_bucket.secure_key_bucket]
}

# Block Public Acess at the Bucket level
resource "aws_s3_bucket_public_access_block" "bastion_block_public_access"{

        bucket = aws_s3_bucket.secure_key_bucket.id
        block_public_acls = true
        block_public_policy = true
        ignore_public_acls = true
        restrict_public_buckets = true

    depends_on = [aws_s3_bucket.secure_key_bucket]

}

# Storing the Bastion Private Key in the S3 bucket
resource "aws_s3_object" "bastion_key_file"{
    bucket = aws_s3_bucket.secure_key_bucket.id
    key = "dummy-bastion-key.pem"
    content = tls_private_key.bastion_key.private_key_pem
    content_type = "text/plain"

    tags={
        Name = "Bastion Private Key"
    }

    depends_on = [aws_s3_bucket.secure_key_bucket]
}

# IAM Role for EC2 to access S3
resource "aws_iam_role" "bastion_iam_role"{
    name = "bastion-s3-access-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "ec2.amazonaws.com"
                },
                Action = ["sts:AssumeRole"]
            }
        ]

    })
}

# IAM Policy for the role above
resource "aws_iam_policy" "bastion_s3_policy"{
    name = "BastionS3AccessPolicy"
    description = "Allows EC2 Instance to access S3 bucket"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Sid = "AllowBastionHostToAccessS3",
            Effect = "Allow",
            Action = "s3:GetObject",
            Resource = "${aws_s3_bucket.secure_key_bucket.arn}/*"
                  
        }]
        
    })
    depends_on = [aws_s3_bucket.secure_key_bucket]
}

# Attach the above IAM Policy to the Role bastion_iam_role
resource "aws_iam_role_policy_attachment" "bastion_s3_attach"{
    role = aws_iam_role.bastion_iam_role.name
    policy_arn = aws_iam_policy.bastion_s3_policy.arn

}

# IAM Policy for Bastion Host to access SSM Standard Parameter Store
resource "aws_iam_policy" "bastion_ssm_access"{
    name = "bastion-ssm-access"
    description = "Allows Bastion Host to access SSM Parameter Store to fetch RDS Credentials"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Sid = "AllowsBastionHostToAccessSSMParameter",
            Effect = "Allow",
            Action = ["ssm:GetParameter"],
            Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/rds/*"
        },
        {
            Sid = "AllowsBastionHostToDecryptSecuredStringParameter",
            Effect = "Allow",
            Action = ["kms:Decrypt"],
            Resource = "*"
            # To implement more Least Privilege
            # Resource = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/alias/aws/ssm"
        }
        ]
    }) 
}

# Attaching the above policy to an IAM Role
resource "aws_iam_role_policy_attachment" "bastion_ssm_access_policy"{
    role = aws_iam_role.bastion_iam_role.name
    policy_arn = aws_iam_policy.bastion_ssm_access.arn
}
# EC2 Instance Profile
resource "aws_iam_instance_profile" "bastion_instance_profile"{
    name = "bastion-instance-profile"
    role = aws_iam_role.bastion_iam_role.name
}

resource "aws_instance" "dummy_bastion_instance"{
    subnet_id = aws_subnet.dummy_public_subnet.id
    ami = "ami-030a63c7124790810"
    instance_type = "t2.micro"

    # Attaching the Instance Profile to this instance
    iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name
    
    vpc_security_group_ids = [aws_security_group.bastion_dummy_sg.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.bastion_keypair.key_name

    tags = {
        Name = "dummy-bastion-host"
        Environment = "Dev"
        Project = "dummyTerraFormProject"
    }

}