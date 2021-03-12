# Módulo para la creación de un aVPC, subdereds y demás
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}
locals { # CONSTANTES
    ingress = {
                "22": {    
                        "to_port": 22
                        "protocol": "tcp"
                        "cidr_blocks": ["0.0.0.0/0"]
                },
                "8080": {    
                        "to_port": 8080
                        "protocol": "tcp"
                        "cidr_blocks": ["0.0.0.0/0"]
                },
                "3306": {    
                        "to_port": 3306
                        "protocol": "tcp"
                        "cidr_blocks": ["10.0.1.0/24"]
                }
              }
}
# Variables
# nombre_vpc= Este es el nombre de la VPC
# cidr_vpc= CIDR de la CPV
# instance_tenancy= Si quiero infra propia para la VPC. default

# VPC
resource "aws_vpc" "vpc"{
    # (Required) The CIDR block for the VPC.
    cidr_block  =  var.cidr_vpc
    # (Optional) A tenancy option for instances launched into the VPC. Default is default, which makes your instances shared on the host. Using either of the other options (dedicated or host) costs at least $2/hr.
    instance_tenancy = var.instance_tenancy
    # (Optional) A boolean flag to enable/disable DNS support in the VPC. Defaults true.
    enable_dns_support = true
    # (Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.
    enable_dns_hostnames = true
    # (Optional) A map of tags to assign to the resource.
    tags = {
        Name = var.nombre_vpc
    }
}

# Subnet 
resource "aws_subnet" "subnet" {
    count                 = length(var.subnets)
    # availability_zone - (Optional) The AZ for the subnet.
    availability_zone     = var.subnets[count.index].subnet_az_name
    # availability_zone_id - (Optional) The AZ ID of the subnet.
    availability_zone_id  = var.subnets[count.index].subnet_az_id
    # vpc_id - (Required) The VPC ID.
    vpc_id                = aws_vpc.vpc.id
    # cidr_block - (Required) The CIDR block for the subnet.
    cidr_block            = var.subnets[count.index].subnet_cidr

    # tags - (Optional) A map of tags to assign to the resource.
    tags = {
        Name = var.subnets[count.index].subnet_name
    }
    # map_public_ip_on_launch - (Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.
    map_public_ip_on_launch = var.subnets[count.index].subnet_public
}

# Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.nombre_vpc}_gateway"
  }
}

# Tablas de Ruta
#      Rutas
# Vincular tablas de ruta
#resource "aws_route_table" "router" {
#
#  vpc_id = aws_vpc.vpc.id
#
#  route {
#    cidr_block = "10.0.1.0/24"
#    gateway_id = aws_internet_gateway.main.id
#  }
#
#  tags = {
#    Name = "main"
#  }
#}
#############################

# Router
resource "aws_route_table" "router" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.nombre_vpc}_router"
  }
}

# Rutas
resource "aws_route" "ruta_internet" {
    route_table_id  = aws_route_table.router.id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.gateway.id
}

# Al ruter le pincho las subredes
resource "aws_route_table_association" "conexion_subredes" {
  count          = length(aws_subnet.subnet) 
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.router.id
}

# SecurityGroups
resource "aws_security_group" "security_group" {
  name        = "${var.nombre_vpc}_sg"
  description = "SecurityGroup para la VPC: ${var.nombre_vpc}"
  
  dynamic "ingress" {    
    iterator = ingress_actual
    for_each = local.ingress
    
    content {
        from_port   = tonumber(ingress_actual.key)
        to_port     = ingress_actual.value["to_port"]
        protocol    = ingress_actual.value["protocol"]
        cidr_blocks = ingress_actual.value["cidr_blocks"]
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# TODO: OUTPUT DEL SECURITY_GROUP.ID