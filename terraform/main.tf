# The configuration for the `remote` backend.
terraform {
  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "yet-another-twitter-analysis"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "yet-another-twitter-analysis-workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "us-west-2"
}

resource "aws_instance" "twitter_data" {
  ami           = "ami-0b6d6dacf350ebc82"
  instance_type = "t2.micro"
  subnet_id     = var.subnet

  tags = {
    Name = "twitter_data"
  }
}

resource "aws_s3_bucket" "twitter_raw_data" {
  bucket        = "twitter_raw_data_bucket"
  subnet_id     = var.subnet
}


variable "subnet" {
  description = "The subnet ID"
  type        = string
  default     = "subnet-98349fd2"
}
