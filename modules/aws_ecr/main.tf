
########## ECR REPOSITORY ###########

resource "aws_ecr_repository" "ecr_ha_repo" {
  name                 = "ecr_ha_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}

