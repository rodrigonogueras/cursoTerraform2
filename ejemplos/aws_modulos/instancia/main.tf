terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}


data "aws_ami" "imagen" {
    count = length(var.aws_ami_id)==0 ? 1 : 0
    most_recent = true
    owners = var.aws_ami_owners
    
    filter {
        name   ="name"
        values = var.aws_ami_nombre
    }
    
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}


resource "aws_instance" "instancia" {
    ami           = length(var.aws_ami_id)==0 ? data.aws_ami.imagen[0].id : var.aws_ami_id
    instance_type = var.tipo_instancia
    key_name      = var.nombre_clave
    
    tags = {
        Name = var.nombre_maquina
    }
    
    security_groups = var.security_groups

}

resource "aws_ebs_volume" "volumen" {
  count = length(var.volumenes.volumenes)
  availability_zone = aws_instance.instancia.availability_zone
  size              = tonumber(var.volumenes.sizes[count.index])
  
  tags = {
    Name = "${aws_instance.instancia.tags.Name}_vol${count.index}"
  }
}

resource "aws_volume_attachment" "asignacion_volumen" {
  count       = length(values(var.volumenes))
  volume_id   = aws_ebs_volume.volumen[count.index].id
  device_name = var.volumenes.mountPoints[count.index]
  instance_id = aws_instance.instancia.id
}
