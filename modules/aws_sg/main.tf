#----------------------------------------------------------
# My Terraform
#
# Autofill Security Group
#
#----------------------------------------------------------

resource "aws_security_group" "ecs_ha_security" {
  name        = "ecs_ha_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id


  ingress {
    description      = "TLS from VPC"
    from_port        = 22   
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80   
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  ingress {
    description      = "TLS from VPC"
    from_port        = 90   
    to_port          = 90
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}
