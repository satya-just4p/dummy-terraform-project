resource "aws_vpc" "dummy_vpc"{
    cidr_block = var.vpc_cidr

    # Below code is necessary to enable VPC's DNSHostNames and DNSSupport
    # so that VPC Endpoint for SSM and Lambda can communicate with each other
    
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "dummy-vpc"
    }
}

resource "aws_subnet" "dummy_public_subnet"{
vpc_id = aws_vpc.dummy_vpc.id
cidr_block = var.public_subnet_cidr
map_public_ip_on_launch = true
availability_zone = "${var.aws_region}a"

tags = {
    Name = "dummy-public-subnet"
}
}

resource "aws_subnet" "dummy_private_subnet"{
    vpc_id = aws_vpc.dummy_vpc.id
    cidr_block = var.private_subnet_cidr
    map_public_ip_on_launch = false
    availability_zone = "${var.aws_region}a"
    tags = {
        Name = "dummy-private-subnet"
    }
}

resource "aws_subnet" "dummy_private_subnetb"{
    vpc_id = aws_vpc.dummy_vpc.id
    cidr_block = var.private_subnet_cidr_b
    map_public_ip_on_launch = false
    availability_zone = "${var.aws_region}b"

    tags = {
        Name = "dummy-private-subnet-b"
    }
}

resource "aws_internet_gateway" "dummy_igw"{
    vpc_id = aws_vpc.dummy_vpc.id
    tags = {
        Name = "dummy-igw"
    }
}

resource "aws_route_table" "dummy_public_rt"{
    vpc_id = aws_vpc.dummy_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dummy_igw.id
    }
    tags = {
        Name = "dummy-public-rt"
    }
}

resource "aws_route_table_association" "dummy_routetable_assoc"{
    subnet_id = aws_subnet.dummy_public_subnet.id
    route_table_id = aws_route_table.dummy_public_rt.id 

}

# Below code creates SG for VPC Endpoint that allows lambda function to access SSM
resource "aws_security_group" "vpc_endpoint_sg"{
    name = "vpc-endpoint-sg"
    description = "Security Group for VPC Endpoint to SSM"
    vpc_id = aws_vpc.dummy_vpc.id

    tags = {
        Name = "vpc-endpoint-sg"
    }
   
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_ingress"{
    security_group_id = aws_security_group.vpc_endpoint_sg.id
    description = "Allows Lambda to access VPC Endpoint for SSM"

    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.lambda_dummy_sg.id
}

resource "aws_vpc_security_group_egress_rule" "vpc_endpoint_egress"{
    security_group_id = aws_security_group.vpc_endpoint_sg.id

    from_port = 0
    to_port = 0
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
}

# The below code creates a VPC endpoint that enables Lambda to access SSM 
# as Lambda is in Private Subnet
resource "aws_vpc_endpoint" "ssm"{
    vpc_id = aws_vpc.dummy_vpc.id
    service_name = "com.amazonaws.${var.aws_region}.ssm"
    vpc_endpoint_type = "Interface"
    subnet_ids = [aws_subnet.dummy_private_subnet.id]
    security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  
    private_dns_enabled = true
    
    tags = {
        Name = "ssm VPC Interface Endpoint"
        Environment = "Dev/Test"
    }

}