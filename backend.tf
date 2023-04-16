provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "mybuckethw"
    key    = "homework.tfstate"
    region = "us-east-1"
   
  }
}
