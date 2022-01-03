terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }
  required_version = ">= 1.1.2"
}

provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}

locals {
  app = "efs-demo"
}

module "vpc" {
  source = "./modules/vpc"
  app    = local.app
}

module "ebs_only_instance" {
  source    = "./modules/ec2"
  app       = local.app
  key_name  = var.key_name
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_1_id
  ebs_only  = true
}

module "ebs_only_ebs" {
  source                 = "./modules/ebs"
  app                    = local.app
  availability_zone      = module.vpc.subnet_1_az
  attachment_instance_id = module.ebs_only_instance.id
}

module "instance_store_instance" {
  source    = "./modules/ec2"
  app       = local.app
  key_name  = var.key_name
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_2_id
  ebs_only  = false
}

module "instance_store_ebs" {
  source                 = "./modules/ebs"
  app                    = local.app
  availability_zone      = module.vpc.subnet_2_az
  attachment_instance_id = module.instance_store_instance.id
}

module "shared_efs" {
  source                  = "./modules/efs"
  app                     = local.app
  vpc_id                  = module.vpc.vpc_id
  ingress_security_groups = [
    module.ebs_only_instance.security_group_id,
    module.instance_store_instance.security_group_id
  ]
  subnet_ids              = [
    module.vpc.subnet_1_id,
    module.vpc.subnet_2_id
  ]
}
