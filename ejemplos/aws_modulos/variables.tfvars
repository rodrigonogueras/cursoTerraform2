id_clave="miclave"
region_aws="eu-west-1"
nombre_vpc="ivan_vpc"
cidr_vpc="10.0.0.0/16"
subnets= [
    {
        "subnet_name": "ivan_publica",
        "subnet_cidr": "10.0.1.0/24",
        "subnet_az_name": null,
        "subnet_az_id": null,
        "subnet_public": true
    },
    {
        "subnet_name": "ivan_privada",
        "subnet_cidr": "10.0.2.0/24",
        "subnet_az_name": null,
        "subnet_az_id": null,
        "subnet_public": false
    }
]