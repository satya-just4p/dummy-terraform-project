resource "aws_security_group" "rds_dummy_sg"{
    name = "dummy-rds-sg"
    vpc_id = aws_vpc.dummy_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ingress"{
    security_group_id = aws_security_group.rds_dummy_sg.id
    description = "Allows MSSQL connections from Bastion Host"

    from_port = 1433
    to_port = 1433
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.bastion_dummy_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "lambda_ingress"{
    security_group_id = aws_security_group.rds_dummy_sg.id
    description = "Allows MSSQL Connections from AWS Lambda"

    from_port = 1433
    to_port = 1433
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.lambda_dummy_sg.id
}

resource "aws_db_subnet_group" "dummy_rds_subnet_group"{
    subnet_ids = [
        aws_subnet.dummy_private_subnet.id,
        aws_subnet.dummy_private_subnetb.id
        ]
    tags ={
        Name = "dummy-rds-subnet-group"
    }

}

resource "aws_db_instance" "dummy_db_instance"{
identifier = "dummydb"
allocated_storage = 20
engine = "sqlserver-ex"
engine_version = "15.00.4073.23.v1"
instance_class = "db.t3.micro"
username = var.db_username
password = var.db_password
parameter_group_name = "default.sqlserver-ex-15.0"
skip_final_snapshot = true
publicly_accessible = false
db_subnet_group_name = aws_db_subnet_group.dummy_rds_subnet_group.name
vpc_security_group_ids = [aws_security_group.rds_dummy_sg.id]

tags = {
    Name = "dummy-rds"
}

}