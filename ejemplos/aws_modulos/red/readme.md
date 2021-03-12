VPC: Virtual Private Cloud
    Infraestructura "FISICA" de RED
    Region
    CIDR = 10.0.0.0/16


Subnets: Red publica
    CIDR = 10.0.1.0/24
Subnets: Red privada
    CIDR = 10.0.2.0/24

Gateways - Conectar a Internet

Route - Enrutar un trafico de red de unos sitios para otros

SecurityGroup - Firewall




-------------------------
VPC:
    Gateway
    
    Red Publica
        Instancia 1 - Nginx        10.0.1.100
    
    Red Privada
        Instancia 2 - Mariadb      10.0.2.100

