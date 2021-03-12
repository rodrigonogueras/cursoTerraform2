terraform { 
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
        }
        null = {
            source = "hashicorp/null"
        }
    }
}

provider docker {
}

provider null {
}

resource "null_resource" "inventario"{
    provisioner "local-exec" {
        command = "rm -f inventario.txt"
    }
}
resource "docker_container" "contenedor_nginx"{ 
    for_each = toset(var.contenedores)
    name = each.key
    image = docker_image.imagen_nginx.latest

    provisioner "local-exec" {
        command = "echo ${self.name}=${self.network_data[0].ip_address} >> inventario.txt"
    }
    
    connection {
        type        = "ssh"
        host        = self.network_data[0].ip_address
        user        = "root"
        password    = "root"
        port        = 22
    }
    provisioner "remote-exec" {
        inline = [
            "echo ${self.name}=${self.network_data[0].ip_address} >> inventario.txt"
            ]
    }
    
    
}

resource "docker_image" "imagen_nginx"{ 
    name = var.imagen_de_contenedor
}


resource "null_resource" "duplicar_inventario"{
    triggers = {
        nada = join("",values(docker_container.contenedor_nginx)[*].ip_address)
    }
    provisioner "local-exec" {
        command = "cp inventario.txt inventario.backup"
    }
}

