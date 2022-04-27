#-----------EIP Association---------------------

resource "aws_eip_association" "eip" {
  instance_id   = var.instance_id
  allocation_id = var.allocation_id
}
