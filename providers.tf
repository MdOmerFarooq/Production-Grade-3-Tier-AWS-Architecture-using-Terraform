terraform {
  backend "s3" {
    bucket = "omer-notes-app-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}
