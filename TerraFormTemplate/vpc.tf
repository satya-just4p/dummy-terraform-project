resource "aws_vpc" "dummy_vpc"{
    cidr_block = var.vpc_cidr

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

