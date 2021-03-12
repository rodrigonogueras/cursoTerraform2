
variable "imagen_de_contenedor" {
    description = "Imagen de contenedor que vamos a utilizar para la creación del contenedor"
    type = string
    default = "nginx:latest"
}
variable "contenedores" {
    description = "Nombres de los contenedores que vamos a generar"
    type = list(string)
    default = []
}