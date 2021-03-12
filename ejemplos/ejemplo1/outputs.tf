
output "inventario"{
    value = join("\n",[for value in docker_container.contenedor_nginx: "${value.name}=${value.ip_address}"])
}






