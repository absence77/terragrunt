
variable "vpc_id" {
    type   = string
}



variable "security_group_id" {
  type   = string
}

variable "subnets" {
  type = list(string)
}

variable "eip" {

}

variable "tag_name" {
  
}

variable "owner_name" {
  
}