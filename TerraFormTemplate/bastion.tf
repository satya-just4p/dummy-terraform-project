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
    cidr_ipv4 = "217.87.114.200/32"
      
}

# RDP Access from my IP
resource "aws_vpc_security_group_ingress_rule" "rdp_access_from_my_ip"{
    security_group_id = aws_security_group.bastion_dummy_sg.id
    description = "Allows RDP access from my IP"

    from_port = 3389
    to_port = 3389
    ip_protocol = "tcp"
    cidr_ipv4 = "217.87.114.200/32"
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

resource "local_file" "private_key_pem"{
content = tls_private_key.bastion_key.private_key_pem
filename = "${path.module}/../SSH/dummy-bastion-key.pem"
file_permission = "0400"
}

resource "aws_instance" "dummy_bastion_instance"{
    subnet_id = aws_subnet.dummy_public_subnet.id
    ami = "ami-030a63c7124790810"
    instance_type = "t2.micro"
    
    vpc_security_group_ids = [aws_security_group.bastion_dummy_sg.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.bastion_keypair.key_name

    tags = {
        Name = "dummy-bastion-host"
    }

}