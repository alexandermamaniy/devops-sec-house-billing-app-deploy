terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "NCI"
}



# Get availability zones (no local zones)
data "aws_availability_zones" "nolocal" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


resource "aws_key_pair" "mtc_auth" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")
}

# ############################### NETWORKING ###############################
# VPC
resource "aws_vpc" "house_billing_vpc" {
  cidr_block           = var.cidr_blocks[0]
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "house-billing-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "house_billing_internet_gateway" {
  vpc_id = aws_vpc.house_billing_vpc.id
  tags = {
    Name = "house_billing_internet_gateway"
  }
}

# Private subnet 1 = var.cidr_blocks[1] = 10.0.1.0/24
resource "aws_subnet" "house_billing_private_subnet_1" {
  cidr_block        = var.cidr_blocks[1]
  vpc_id            = aws_vpc.house_billing_vpc.id
  availability_zone = data.aws_availability_zones.nolocal.names[0]
  tags = {
    Name = "house_billing_private_subnet_1"
  }
}

# Private subnet 2 = var.cidr_blocks[2] = 10.0.2.0/24
resource "aws_subnet" "house_billing_private_subnet_2" {
  cidr_block        = var.cidr_blocks[2]
  vpc_id            = aws_vpc.house_billing_vpc.id
  availability_zone = data.aws_availability_zones.nolocal.names[1]
  tags = {
    Name = "house_billing_private_subnet_2"
  }
}

# Public subnet 1 var.cidr_blocks[3] = 10.0.3.0/24
resource "aws_subnet" "house_billing_public_subnet_1" {
  cidr_block        = var.cidr_blocks[3]
  vpc_id            = aws_vpc.house_billing_vpc.id
  availability_zone = data.aws_availability_zones.nolocal.names[0]
  tags = {
    Name = "house_billing_public_subnet_1"
  }
}

# Public subnet 2 = var.cidr_blocks[4] = 10.0.3.0/24
resource "aws_subnet" "house_billing_public_subnet_2" {
  cidr_block        = var.cidr_blocks[4]
  vpc_id            = aws_vpc.house_billing_vpc.id
  availability_zone = data.aws_availability_zones.nolocal.names[1]
  tags = {
    Name = "house_billing_public_subnet_2"
  }
}

# Public route table
resource "aws_route_table" "house_billing_public_route_table" {
  vpc_id = aws_vpc.house_billing_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.house_billing_internet_gateway.id
  }
  tags = {
    Name = "house_billing_public_route_table"
  }
}

# Public route table association with public subnet 1
resource "aws_route_table_association" "house_billing_route_table_associate_public_subnet_1" {
  subnet_id      = aws_subnet.house_billing_public_subnet_1.id
  route_table_id = aws_route_table.house_billing_public_route_table.id
}

# Public route table association with public subnet 2
resource "aws_route_table_association" "house_billing_route_table_associate_public_subnet_2" {
  subnet_id      = aws_subnet.house_billing_public_subnet_2.id
  route_table_id = aws_route_table.house_billing_public_route_table.id
}

# Private route table for private subnet 1
resource "aws_route_table" "house_billing_private_subnet_1_route_table" {
  vpc_id = aws_vpc.house_billing_vpc.id
  tags = {
    Name = "house_billing_private_subnet_1_route_table_"
  }
}
#Private route table for private subnet 2
resource "aws_route_table" "house_billing_private_subnet_2_route_table" {
  vpc_id = aws_vpc.house_billing_vpc.id
  tags = {
    Name = "house_billing_private_subnet_2_route_table"
  }
}

# Private route table association with private subnet 1
resource "aws_route_table_association" "house_billing_route_table_associate_private_subnet_1" {
  subnet_id      = aws_subnet.house_billing_private_subnet_1.id
  route_table_id = aws_route_table.house_billing_private_subnet_1_route_table.id
}

# Private route table association with private subnet 2
resource "aws_route_table_association" "house_billing_route_table_associate_private_subnet_2" {
  subnet_id      = aws_subnet.house_billing_private_subnet_2.id
  route_table_id = aws_route_table.house_billing_private_subnet_2_route_table.id
}


# ############################### SECURITY GROUPS ###############################

# Security Group for NAT Instance
resource "aws_security_group" "house_billing_nat_security_group" {
  name        = "house_billing_nat_security_group"
  description = "Security Group for NAT instance"
  vpc_id      = aws_vpc.house_billing_vpc.id
  tags = {
    Name = "house_billing_nat_security_group"
  }
}

# Security Group for Web Service (Django rest API)
resource "aws_security_group" "house_billing_web_rest_api_service_security_group" {
  name        = "house_billing_web_rest_api_service_security_group"
  description = "Security Group for Web Service (Django rest API)"
  vpc_id      = aws_vpc.house_billing_vpc.id
  tags = {
    Name = "house_billing_web_rest_api_service_security_group"
  }
}

# Security Group for Nginx Proxy
resource "aws_security_group" "house_billing_nginx_proxy_security_group" {
  name        = "house_billing_nginx_proxy_security_group"
  description = "Security Group for NGINX Proxy"
  vpc_id      = aws_vpc.house_billing_vpc.id
  tags = {
    Name = "house_billing_nginx_proxy_security_group"
  }
}

# Security Group for RDS
resource "aws_security_group" "house_billing_rds_security_group" {
  name        = "house_billing_rds_security_group"
  description = "Security Group for RDS instance"
  vpc_id      = aws_vpc.house_billing_vpc.id
  tags = {
    Name = "house_billing_rds_security_group"
  }
}


# # Security Group for RDS
# resource "aws_security_group" "gluon-sg-rds" {
#   name        = "gluon-sg-rds"
#   description = "Security Group for RDS"
#   vpc_id      = aws_vpc.house_billing_vpc.id
#   tags = {
#     Name = "gluon-sg-rds"
#   }
# }

# ############################### SECURITY GROUPS RULES ###############################

# NAT Instance Security group rule to allow SSH from remote ip
resource "aws_security_group_rule" "house_billing_remote_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.remoteip]
  security_group_id = aws_security_group.house_billing_nat_security_group.id
}

# NAT Instance security group rule to allow all traffic from within the VPC
resource "aws_security_group_rule" "house_billing_vpc_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.cidr_blocks[0]]
  security_group_id = aws_security_group.house_billing_nat_security_group.id
}

# NAT Instance security group rule to allow outbound traffic
resource "aws_security_group_rule" "house_billing_outbound_nat_instance" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.house_billing_nat_security_group.id
}

# Web Service (Django rest API) security group rule to allow all traffic from public subnet 1
resource "aws_security_group_rule" "house_billing_web_rest_api_service_inbound_private_subnet_1" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.cidr_blocks[3]]
  security_group_id = aws_security_group.house_billing_web_rest_api_service_security_group.id
}

# Web Service (Django rest API) security group rule to allow all traffic from public subnet 2
resource "aws_security_group_rule" "house_billing_web_rest_api_service_inbound_private_subnet_2" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.cidr_blocks[4]]
  security_group_id = aws_security_group.house_billing_web_rest_api_service_security_group.id
}


# Web Service (Django rest API) instance security group rule to allow outbound access to anywhere
resource "aws_security_group_rule" "house_billing_web_rest_api_service_outbound_to_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.house_billing_web_rest_api_service_security_group.id
}

# Nginx Proxy security group rule to allow traffic by port 80  from anywhere
resource "aws_security_group_rule" "house_billing_inbound_nginx_proxy_instance_from_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.house_billing_nginx_proxy_security_group.id
}

resource "aws_security_group_rule" "house_billing_inbound_nginx_proxy_instance_from_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.remoteip]
  security_group_id = aws_security_group.house_billing_nginx_proxy_security_group.id
}

# Nginx Proxy instance security group rule to allow outbound traffic
resource "aws_security_group_rule" "house_billing_outbound_nginx_proxy_instance_to_anywhere" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.house_billing_nginx_proxy_security_group.id
}

# # RDS security group rule to allow all traffic from private subnet 1
# resource "aws_security_group_rule" "house_billing_rds_inbound_private_subnet_1" {
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = [var.cidr_blocks[1]]
#   security_group_id = aws_security_group.house_billing_rds_security_group.id
# }
#
# # RDS security group rule to allow all traffic from private subnet 2
# resource "aws_security_group_rule" "house_billing_rds_inbound_private_subnet_2" {
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = [var.cidr_blocks[2]]
#   security_group_id = aws_security_group.house_billing_rds_security_group.id
# }

# RDS security group rule to allow MYSQL traffic by port 3306 from subnet 1
resource "aws_security_group_rule" "house_billing_rds_mysql_inbound_from_private_subnet_1" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_blocks[1]]
  security_group_id = aws_security_group.house_billing_rds_security_group.id
}

# RDS security group rule to allow all traffic from private subnet 2
resource "aws_security_group_rule" "house_billing_rds_mysql_inbound_from_private_subnet_2" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_blocks[2]]
  security_group_id = aws_security_group.house_billing_rds_security_group.id
}

# RDS instance security group rule to allow outbound traffic to subnet 1
resource "aws_security_group_rule" "house_billing_outbound_rds_instance_to_subnet_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.cidr_blocks[1]]
  security_group_id = aws_security_group.house_billing_rds_security_group.id
}

# RDS instance security group rule to allow outbound traffic to subnet 2
resource "aws_security_group_rule" "house_billing_outbound_rds_instance_to_subnet_2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.cidr_blocks[2]]
  security_group_id = aws_security_group.house_billing_rds_security_group.id
}
####################################### SUBNET RDS #######################################

# create the subnet group for the rds instance
resource "aws_db_subnet_group" "house_billing_database_subnet_group" {
  name        = "house_billing_database_subnet_group"
  subnet_ids  = [aws_subnet.house_billing_private_subnet_1.id, aws_subnet.house_billing_private_subnet_2.id]
  description = "subnets for house billing database instace"

  tags = {
    Name = "house_billing_database_subnet_group"
  }
}

####################################### INSTANCES #######################################

# Build the NAT Instance
resource "aws_instance" "house_billing_nat_instance" {
  ami                         = data.aws_ami.fck-nat-amzn2_image.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.house_billing_public_subnet_1.id # add public subnet 2 too
  vpc_security_group_ids      = [aws_security_group.house_billing_nat_security_group.id, ]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.mtc_auth.id

  # Root disk for NAT instance
  root_block_device {
    volume_size = "2"
    volume_type = "gp2"
    encrypted   = true
  }
  tags = {
    Name = "house_billing_nat_instance"
  }
}

# Web REST API serivce Instance
resource "aws_instance" "house_billing_web_rest_api_instance" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu24_image.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.house_billing_web_rest_api_service_security_group.id]
  subnet_id              = aws_subnet.house_billing_private_subnet_1.id
  # user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
  }

  tags = {
    Name = "house_billing_web_rest_api_instance"
  }
}

# Nginx Proxy Instance

resource "aws_instance" "house_billing_nginx_proxy_instance" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu24_image.id
  key_name               = aws_key_pair.mtc_auth.id
  vpc_security_group_ids = [aws_security_group.house_billing_nginx_proxy_security_group.id]
  subnet_id              = aws_subnet.house_billing_public_subnet_1.id
  # user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
  }

  tags = {
    Name = "house_billing_nginx_proxy_instance"
  }
}


# create the rds instance
resource "aws_db_instance" "house-billing-db-instance" {
  engine                 = "mysql"
  engine_version         = "8.0"
  multi_az               = false
  identifier             = "house-billing-db-instance"
  username               = "marenestasloca"
  password               = "marenestasloca1234"
  instance_class         = "db.t3.micro"
  allocated_storage      = 200
  db_subnet_group_name   = aws_db_subnet_group.house_billing_database_subnet_group.name
  vpc_security_group_ids = [aws_security_group.house_billing_rds_security_group.id]
  availability_zone      = data.aws_availability_zones.nolocal.names[0]
  db_name                = "housebillingapplicationdb"
  skip_final_snapshot    = true
}


#
#
# resource "aws_instance" "frontend" {
#   instance_type = "t2.micro"
#   ami           = data.aws_ami.server_ami.id
#   key_name      = aws_key_pair.mtc_auth.id
#   # create a new securit group for this
#   vpc_security_group_ids      = [aws_security_group.house_billing_nat_security_group.id]
#   subnet_id                   = aws_subnet.house_billing_public_subnet_1.id
#   user_data                   = file("userdata.tpl")
#   associate_public_ip_address = true
#   source_dest_check           = false
#
#   root_block_device {
#     volume_size = 20
#     volume_type = "gp2"
#     encrypted   = true
#   }
#
#   tags = {
#     Name = "gluon-nginx"
#   }
# }


# create the subnet group for the rds instance
# resource "aws_db_subnet_group" "database_subnet_group" {
#   name        = "database-subnets"
#   subnet_ids  = [aws_subnet.house_billing_private_subnet_1.id, aws_subnet.house_billing_private_subnet_2.id]
#   description = "subnets for database instace"
#
#   tags = {
#     Name = "database-subnets"
#   }
# }

# # create security group for the web server
# resource "aws_security_group" "webserver_security_group" {
#   name        = "webserver security group"
#   description = "enable http access on port 80"
#   vpc_id      = aws_vpc.gluon-vpc.id
#
#   ingress {
#     description = "http access"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tpc"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "webserver security group"
#   }
# }
#
# # create security group for the database
# resource "aws_security_group" "database_security_group" {
#   name        = "database security group"
#   description = "enable mysql/aurora access on port 3306"
#   vpc_id      = aws_vpc.gluon-vpc.id
#
#   ingress {
#     description     = "mysql/aurora access"
#     from_port       = 3306
#     to_port         = 3306
#     protocol        = "tcp"
#     security_groups = [aws_security_group.webserver_security_group.id]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "database security group"
#   }
# }

# use data source to get all avalablility zones in region
# data "aws_availability_zones" "available_zones" {}

# # create the rds instance
# resource "aws_db_instance" "db_instance" {
#   engine                 = "mysql"
#   # engine_version         = "8.0"
#   multi_az               = false
#   identifier             = "dev-rds-instance"
#   username               = "marenestasloca"
#   password               = "marenestasloca1234"
#   instance_class         = "db.t2.micro"
#   allocated_storage      = 200
#   db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.name
#   # vpc_security_group_ids = [aws_security_group.house_billing_web_service_security_group]
#   availability_zone      = data.aws_availability_zones.available_zones.names[0]
#   db_name                = "applicationdb"
#   skip_final_snapshot    = true
# }
#
# # Route table entry to forward traffic to NAT instance
# resource "aws_route" "outbound-nat-route" {
#   route_table_id         = aws_route_table.gluon-rt-private1.id
#   destination_cidr_block = "0.0.0.0/0"
#   network_interface_id   = aws_instance.house_billing_nat_instance.primary_network_interface_id
# }


# Next steps
# - Create RDS security group
# - no exponer RDS a NAT
# - Fix RDS paramentres