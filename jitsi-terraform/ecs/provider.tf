provider "aws" {
  default_tags {
    tags = {
      env="dev"
      purpose="jitsi"
    }
  }
}
