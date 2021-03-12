terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = var.region_aws
    profile = "default"
}

module "claves" {
    source = "./claves"
    longitud_clave_rsa = 4096
    id_clave = var.id_clave
}

module "red" {
    source      = "./red"
    nombre_vpc  = "ivan-vpc"
    cidr_vpc    = "10.0.0.0/16"
    subnets     = [
                {
                    "subnet_name": "ivan-publica",
                    "subnet_cidr": "10.0.1.0/24",
                    "subnet_az_name": null,
                    "subnet_az_id": null,
                    "subnet_public": true
                },
                {
                    "subnet_name": "ivan-privada",
                    "subnet_cidr": "10.0.2.0/24",
                    "subnet_az_name": null,
                    "subnet_az_id": null,
                    "subnet_public": false
                }
            ]

}

module "instancia" {
    source = "./instancia"
    aws_ami_owners=var.aws_ami_owners
    aws_ami_nombre=var.aws_ami_nombre
    volumenes = var.volumenes
    nombre_clave=var.id_clave
    nombre_maquina=var.nombre_maquina
    security_groups=module.red.OUTPUT_DEL_SECURITY_GROUP_ID
}

