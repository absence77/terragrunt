terraform {  
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "ecs-ha-tfstate-test"
    key    = "dev/tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}


module "aws_network" {
  source               = "./modules/aws_network"
  vpc_cidr             = var.vpc_cidr
  env                  = var.env
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tag_name             = var.tag_name
  owner_name           = var.owner_name
}

module "aws_sg" {
  source      = "./modules/aws_sg"
  depends_on  = [module.aws_network]
  vpc_id      = module.aws_network.vpc_id
  tag_name    = var.tag_name
  owner_name  = var.owner_name

}


module "aws_bastion" {
  source             = "./modules/aws_bastion"
  subnet_id          = element(module.aws_network.public_subnet_ids, 1)
  security_group_id  = module.aws_sg.securitygroup_id
  owner_name         = var.owner_name
  tag_name           = var.tag_name
  
}


module "aws_ecr" {
  source       = "./modules/aws_ecr"
  tag_name     = var.tag_name
  owner_name   = var.owner_name
}

module "aws_ecs" {
  source             = "./modules/aws_ecs"
  image_name         = module.aws_ecr.ecr_repo_url
  subnets            = module.aws_network.private_subnet_ids
  security_group_id  = module.aws_sg.securitygroup_id
  elb_name           = module.aws_alb.alb_name
  target_group_arn   = module.aws_alb.target_group_arn
  target_group90_arn = module.aws_alb.target_group90_arn
  tag_name           = var.tag_name
  owner_name         = var.owner_name
}

module "aws_alb" {
  source              = "./modules/aws_alb"
  vpc_id              = module.aws_network.vpc_id
  security_group_id   = module.aws_sg.securitygroup_id
  subnets             = module.aws_network.public_subnet_ids
  eip                 = module.aws_network.aws_eip_public
  tag_name            = var.tag_name
  owner_name          = var.owner_name
}


module "aws_eip_association" {
  source = "./modules/aws_eip_association"
  instance_id   = module.aws_bastion.instance_id
  allocation_id = module.aws_network.aws_eip_id
  
}

###### Pipeline ####

module "aws_pipeline" {
  source          = "./modules/aws_pipeline"
  servicename1    = module.aws_ecs.servicename1
  clustername     = module.aws_ecs.clustername
  servicename2    = module.aws_ecs.servicename2
  tag_name        = var.tag_name
  owner_name      = var.owner_name
}
