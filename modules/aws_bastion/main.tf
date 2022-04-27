
############ Create KEY PAIR ############
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}



############ Bastion Host ################

resource "aws_instance" "bastionhost" {
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = aws_key_pair.kp.key_name
  subnet_id         = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
   
  tags = {
    Owner = "${var.owner_name}"
    Name  = "BastionHost (ECS-HA)"
  }

}
