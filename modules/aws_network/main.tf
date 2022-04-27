#----------------------------------------------------------
# Provision:
#  - VPC
#  - Internet Gateway
#  - XX Public Subnets
#  - XX Private Subnets
#  - XX NAT Gateways in Public Subnets to give access to Internet from Private Subnets
#
#----------------------------------------------------------

#==============================================================

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}

#-------------Public Subnets and Routing----------------------------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}


resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)

}


#----- Elastic IP  for Bastion--------------------------


resource "aws_eip" "nat" {
  vpc   = true
  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}

#------Elastic Ip for NAT------------

resource "aws_eip" "private" {
  vpc   = true
  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}



#---------NAT Gateway----------------

resource "aws_nat_gateway" "natgw" {
  connectivity_type = "public"
  allocation_id     = aws_eip.private.allocation_id
  subnet_id         = element(aws_subnet.public_subnets[*].id, 0)

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}

#--------------Private Subnets and Routing-------------------------

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}

resource "aws_route_table" "PrivateRoute" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}

############# RT_Association_Private ############

resource "aws_route_table_association" "private1" {
  subnet_id      = element(aws_subnet.private_subnets[*].id, 0)
  route_table_id = aws_route_table.PrivateRoute.id
  
}

resource "aws_route_table_association" "private2" {
  subnet_id      = element(aws_subnet.private_subnets[*].id, 1)
  route_table_id = aws_route_table.PrivateRoute.id
}
