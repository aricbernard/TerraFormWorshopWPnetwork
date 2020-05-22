# Ensure that environment variables are configured for access key based log on
# PowerShell example:
# $env:AWS_ACCESS_KEY_ID="<Key ID>"
# $env:AWS_SECRET_ACCESS_KEY="<Key>"

/****** Note to reviewer - I suspect certificates are createing a problem with my linkage to the backend
terraform {
  backend "remote" {
    hostname = "tfe-tfe-web-alb-985732316.us-west-1.elb.amazonaws.com"
    organization = "ACME"

    workspaces {
      name = "network-WordPress"
    }
  }
}
*/

/*
Incomplete due to lack of time:
  Peering
  Routes
  Security Groups
  Bastion Hosts
  Optimize code
  Variablize code (all values currently static)

  Create separate code for Wordpress application deployment
    Allows for segregation of responsibilities between network/security and app teams
    Allows for potential use of customers existing network implemenation
*/

#### Prodcution US
provider "aws" {
  alias = "uswest1"
  region = "us-west-1"
}

data "aws_availability_zones" "azs1" {
  provider = aws.uswest1
  state = "available"
}

module "vpc1" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
       aws = aws.uswest1
  }

  name = "WP-US-Prod"
  cidr = "10.254.0.0/16"

  azs             = [data.aws_availability_zones.azs1.names[0], data.aws_availability_zones.azs1.names[1]]

  private_subnets  = ["10.254.0.0/24", "10.254.1.0/24"]
  public_subnets  = ["10.254.50.0/24", "10.254.51.0/24"]
  database_subnets = ["10.254.100.0/24", "10.254.101.0/24"]

  enable_nat_gateway = true
}

module "adminvpc1" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
       aws = aws.uswest1
  }

  name = "Admin-US-Prod"
  cidr = "10.254.0.0/16"

  azs             = [data.aws_availability_zones.azs1.names[0], data.aws_availability_zones.azs1.names[1]]

  public_subnets  = ["10.254.150.0/24", "10.254.151.0/24"]
  
  enable_nat_gateway = true
}

#### DR US
provider "aws" {
  alias = "uswest2"
  region = "us-west-2"
}

data "aws_availability_zones" "azs2" {
  provider = aws.uswest2
  state = "available"
}

module "vpc2" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.uswest2
  }

  name = "WP-US-DR"
  cidr = "10.254.0.0/16"

  azs             = [data.aws_availability_zones.azs2.names[0], data.aws_availability_zones.azs2.names[1]]

  private_subnets  = ["10.254.2.0/24", "10.254.3.0/24"]
  public_subnets  = ["10.254.52.0/24", "10.254.53.0/24"]
  database_subnets = ["10.254.102.0/24", "10.254.103.0/24"]

  enable_nat_gateway = true
}

module "adminvpc2" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
       aws = aws.uswest2
  }

  name = "Admin-DR-Prod"
  cidr = "10.254.0.0/16"

  azs             = [data.aws_availability_zones.azs2.names[0], data.aws_availability_zones.azs2.names[1]]

  public_subnets  = ["10.254.152.0/24", "10.254.153.0/24"]
  
  enable_nat_gateway = true
}

#### Replica EU
provider "aws" {
  alias = "eucentral1"
  region = "eu-central-1"
}

data "aws_availability_zones" "azs3" {
  provider = aws.eucentral1
  state = "available"
}

module "vpc3" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.eucentral1
  }

  name = "WP-EU-Replica"
  cidr = "10.254.0.0/16"

  azs             = [data.aws_availability_zones.azs3.names[0], data.aws_availability_zones.azs3.names[1],data.aws_availability_zones.azs3.names[2]]

  private_subnets  = ["10.254.4.0/24", "10.254.5.0/24","10.254.6.0/24"]
  public_subnets  = ["10.254.54.0/24", "10.254.55.0/24","10.254.56.0/24"]
  database_subnets = ["10.254.104.0/24", "10.254.105.0/24","10.254.106.0/24"]

  enable_nat_gateway = true
}

module "adminvpc3" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
       aws = aws.eucentral1
  }

  name = "Admin-EU-Prod"
  cidr = "10.254.0.0/16"

  azs             = [data.aws_availability_zones.azs3.names[0], data.aws_availability_zones.azs3.names[1]]

  public_subnets  = ["10.254.154.0/24", "10.254.155.0/24"]
  
  enable_nat_gateway = true
}