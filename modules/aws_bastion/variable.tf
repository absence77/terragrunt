variable "ami" {
  type    = string
  default = "ami-0d527b8c289b4af7f"
}


variable "instance_type" {
  type    = string
  default = "t2.micro"
}


variable "key_name" {
  type    = string
  default = "faridkey"
}

variable "subnet_id" { 
  type   = string
}

variable "security_group_id" {
  type   = string
}

variable "tag_name" {}

variable "owner_name" {
  
}
