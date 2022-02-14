provider "aws" {
  region = "ap-south-1"
  default_tags {
    tags = {
      env="dev"
      purpose="jitsi"
    }
  }
}