# The configuration for the `remote` backend.
terraform  {
  backend "remote" {
    # The name of your terraform  Cloud organization.
    organization = "yet-another-twitter-analysis"

    # The name of the terraform  Cloud workspace to store terraform  state files in.
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

resource "aws_s3_bucket" "yet-another-twitter-analysis-bucket" {
  bucket        = "yet-another-twitter-analysis-bucket"
}

resource "aws_sqs_queue" "twitter_data_queue" {
  name                      = "twitter-analysis-queue"
  max_message_size          = 2048
  message_retention_seconds = 86400
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.twitter_data_queue_deadletter.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "twitter_data_queue_deadletter" {
  name = "twitter-data-deadletter-queue"
}

resource "aws_sqs_queue_redrive_allow_policy" "twitter_data_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.twitter_data_queue_deadletter.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.twitter_data_queue.arn]
  })
}

resource "aws_ecr_repository" "yet-another-twitter-analysis-ecr" {
  name = "yet-another-twitter-analysis-ecr"
}



variable "subnet" {
  description = "The subnet ID"
  type        = string
  default     = "subnet-98349fd2"
}
