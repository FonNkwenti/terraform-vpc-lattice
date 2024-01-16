terraform {
  backend "s3" {
    bucket = "tf-remote-state-03012024"
    key    = "terraform.tfstate"
    region = "us-west-1"
    profile = "default"
  }
}