terraform {
  required_version = "~> 1.14.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC 1 for the failing VPC Peering Connection
module "project1-vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.40.0.0/16"
  vpc_name = "project1-vpc"
  tags = local.tags
}

resource "aws_internet_gateway" "internet_gateway-1" {
  vpc_id = module.project1-vpc.vpc_id

  tags = {
    Name = "main"
  }
}
# VPC 2 the Hub for the peering connections
module "project2-vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.80.0.0/16"
  vpc_name = "project2-vpc"
  tags = local.tags
}
# No need for an Internet Gateway for this VPC.

# VPC 3 for the working VPC Peering connection
module "project3-vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.120.0.0/16"
  vpc_name = "project3-vpc"
  tags = local.tags
}

resource "aws_internet_gateway" "internet_gateway-3" {
  vpc_id = module.project3-vpc.vpc_id

  tags = {
    Name = "main"
  }
}

#################################################### VPC 1 Subnets ####################################################
# Subnets for VPC 1
# Public subnet 1
module "project1-public-subnet" {
  source            = "./modules/subnet"
  vpc_id            = module.project1-vpc.vpc_id
  subnet_cidr       = "10.40.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = local.tags
  subnet_name = "public-subnet1"
}
module "project1-public-subnet2" {
  source            = "./modules/subnet"
  vpc_id            = module.project1-vpc.vpc_id
  subnet_cidr       = "10.40.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[4]
  tags = local.tags
  subnet_name = "public-subnet2"
}
module "project1-private-subnet" {
  source            = "./modules/subnet"
  vpc_id            = module.project1-vpc.vpc_id
  subnet_cidr       = "10.40.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = local.tags
  subnet_name = "private-subnet1"
}

# Route table for VPC 1
# This is for the public subnet to allow outbound interent traffic
resource "aws_route_table" "project1_public_rt" {
  vpc_id = module.project1-vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway-1.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "project1_public_subnet_assoc" {
  subnet_id      = module.project1-public-subnet.subnet_id
  route_table_id = aws_route_table.project1_public_rt.id
}
resource "aws_route_table_association" "project1_public_subnet2_assoc" {
  subnet_id      = module.project1-public-subnet2.subnet_id
  route_table_id = aws_route_table.project1_public_rt.id
}

# Route table for the private subnet to allow outbound traffic to the internet via a NAT Gateway (not implemented in this code)
resource "aws_eip" "project1_nat_eip" {
  tags = local.tags
}
resource "aws_nat_gateway" "project1_nat" {
  allocation_id = aws_eip.project1_nat_eip.id
  subnet_id     = module.project1-public-subnet.subnet_id

  tags = local.tags
}
resource "aws_route_table" "project1_private_rt" {
  vpc_id = module.project1-vpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.project1_nat.id
  }
  lifecycle {
    ignore_changes = [route]
  }

  tags = local.tags
}

resource "aws_route_table_association" "project1_private_subnet_assoc" {
  subnet_id      = module.project1-private-subnet.subnet_id
  route_table_id = aws_route_table.project1_private_rt.id
}



#################################################### VPC 2 Subnets ####################################################
# Subnets for VPC 2
# Subnet 1
module "project2-private-subnet" {
  source            = "./modules/subnet"
  vpc_id            = module.project2-vpc.vpc_id
  subnet_cidr       = "10.80.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = local.tags
  subnet_name = "private-subnet1"
}
# Subnet 2
module "project2-private-subnet2" {
  source            = "./modules/subnet"
  vpc_id            = module.project2-vpc.vpc_id
  subnet_cidr       = "10.80.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[5]
  tags = local.tags
  subnet_name = "private-subnet2"
}

resource "aws_route_table" "project2_private_rt" {
  vpc_id = module.project2-vpc.vpc_id

  route {
    cidr_block = module.project2-vpc.vpc_cidr_block
    gateway_id = "local"
  }
  lifecycle {
    ignore_changes = [route]
  }

  tags = local.tags
}
# Subnet 1 Association to Route Table
resource "aws_route_table_association" "project2_private_subnet_assoc" {
  subnet_id      = module.project2-private-subnet.subnet_id
  route_table_id = aws_route_table.project2_private_rt.id
}
# Subnet 2 Association to Route Table
resource "aws_route_table_association" "project2_private_subnet2_assoc" {
  subnet_id      = module.project2-private-subnet2.subnet_id
  route_table_id = aws_route_table.project2_private_rt.id
}
#################################################### VPC 3 Subnets ####################################################
# Subnets for VPC 3
# Public subnet 1
module "project3-public-subnet" {
  source            = "./modules/subnet"
  vpc_id            = module.project3-vpc.vpc_id
  subnet_cidr       = "10.120.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = local.tags
  subnet_name = "public-subnet1"
}
# Public subnet 2
module "project3-public-subnet2" {
  source            = "./modules/subnet"
  vpc_id            = module.project3-vpc.vpc_id
  subnet_cidr       = "10.120.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = local.tags
  subnet_name = "public-subnet2"
}
module "project3-private-subnet" {
  source            = "./modules/subnet"
  vpc_id            = module.project3-vpc.vpc_id
  subnet_cidr       = "10.120.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = local.tags
  subnet_name = "private-subnet1"
}






# Route table for VPC 3
# This is for the public subnet to allow outbound interent traffic
resource "aws_route_table" "project3_public_rt" {
  vpc_id = module.project3-vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway-3.id
  }

  tags = local.tags
}
# Rpite fpr 1st public subnet
resource "aws_route_table_association" "project3_public_subnet_assoc" {
  subnet_id      = module.project3-public-subnet.subnet_id
  route_table_id = aws_route_table.project3_public_rt.id
}
# Route for 2nd public subnet
resource "aws_route_table_association" "project3_public_subnet_assoc2" {
  subnet_id      = module.project3-public-subnet2.subnet_id
  route_table_id = aws_route_table.project3_public_rt.id
}
# Route table for the private subnet to allow outbound traffic to the internet via a NAT Gateway (not implemented in this code)
resource "aws_eip" "project3_nat_eip" {
  tags = local.tags
}
resource "aws_nat_gateway" "project3_nat" {
  allocation_id = aws_eip.project3_nat_eip.id
  subnet_id     = module.project3-public-subnet.subnet_id

  tags = local.tags
}
resource "aws_route_table" "project3_private_rt" {
  vpc_id = module.project3-vpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.project3_nat.id
  }
  lifecycle {
    ignore_changes = [route]
  }

  tags = local.tags
}

resource "aws_route_table_association" "project3_private_subnet_assoc" {
  subnet_id      = module.project3-private-subnet.subnet_id
  route_table_id = aws_route_table.project3_private_rt.id
}



# VPC Peering Connection between VPC 2 and VPC 1 (failing connection)

resource "aws_vpc_peering_connection" "vpc_2_to_vpc_1" {
  vpc_id        = module.project2-vpc.vpc_id
  peer_vpc_id   = module.project1-vpc.vpc_id
  auto_accept   = false

  tags = local.tags
}

# VPC Peering Connection between VPC 2 and VPC 3 (Working connection)

resource "aws_vpc_peering_connection" "vpc_2_to_vpc_3" {
  vpc_id        = module.project2-vpc.vpc_id
  peer_vpc_id   = module.project3-vpc.vpc_id
  auto_accept   = false

  tags = local.tags
}



########################################################### VPC Peering Connection Route Configuration ###########################################################

# VPC Peering Connection Acceptance for VPC 2 and VPC 1

resource "aws_vpc_peering_connection_accepter" "accept_vpc_2_to_vpc_1" {
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_2_to_vpc_1.id
  auto_accept               = true

  tags = local.tags
  depends_on = [ aws_vpc_peering_connection.vpc_2_to_vpc_1 ]
}

# Route for VPC 2 to reach VPC 1 via the peering connection
resource "aws_route" "vpc_2_to_vpc_1" {
  route_table_id            = aws_route_table.project1_private_rt.id
  destination_cidr_block    = module.project2-vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_2_to_vpc_1.id

  depends_on = [
    aws_vpc_peering_connection_accepter.accept_vpc_2_to_vpc_1,
    aws_route_table_association.project1_private_subnet_assoc
  ]
}





# VPC Peering Connection Acceptance for VPC 2 and VPC 3

resource "aws_vpc_peering_connection_accepter" "accept_vpc_2_to_vpc_3" {
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_2_to_vpc_3.id
  auto_accept               = true

  tags = local.tags
  
  depends_on = [ aws_vpc_peering_connection.vpc_2_to_vpc_3 ]
}

# Route for VPC 2 to reach VPC 3 via the peering connection
resource "aws_route" "vpc_2_to_vpc_3" {
  route_table_id            = aws_route_table.project3_private_rt.id
  destination_cidr_block    = module.project2-vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_2_to_vpc_3.id

  depends_on = [
    aws_vpc_peering_connection_accepter.accept_vpc_2_to_vpc_3,
    aws_route_table_association.project3_private_subnet_assoc
  ]
}








######## 3 VPC Peering Connection Route for VPC 1 to reach VPC 2 via the peering connection

resource "aws_route" "vpc_1_to_vpc_2" {
  route_table_id            = aws_route_table.project2_private_rt.id
  destination_cidr_block    = module.project1-vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_2_to_vpc_1.id

  depends_on = [
    aws_vpc_peering_connection_accepter.accept_vpc_2_to_vpc_1,
    aws_route_table_association.project2_private_subnet_assoc,
    aws_route_table_association.project2_private_subnet2_assoc
  ]
}

# VPC Peering Connection Route for VPC 3 to reach VPC 2 via the peering connection
resource "aws_route" "vpc_3_to_vpc_2" {
  route_table_id            = aws_route_table.project2_private_rt.id
  destination_cidr_block    = module.project3-vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_2_to_vpc_3.id

  depends_on = [
    aws_vpc_peering_connection_accepter.accept_vpc_2_to_vpc_3,
    aws_route_table_association.project2_private_subnet_assoc,
    aws_route_table_association.project2_private_subnet2_assoc
  ]
}



#####################################      ROUTING SUCCESSFUL VPC PEERING CONNECTIONS      #####################################
#####################################      ROUTING SUCCESSFUL VPC PEERING CONNECTIONS      #####################################
#####################################      ROUTING SUCCESSFUL VPC PEERING CONNECTIONS      #####################################
#####################################      ROUTING SUCCESSFUL VPC PEERING CONNECTIONS      #####################################
#####################################      ROUTING SUCCESSFUL VPC PEERING CONNECTIONS      #####################################
#####################################      ROUTING SUCCESSFUL VPC PEERING CONNECTIONS      #####################################




