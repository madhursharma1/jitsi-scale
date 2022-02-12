data "aws_vpc" "jitsi-vpc" {
 tags = {
   Name = "vpc-jitsi"
 } 
}

data "aws_subnet_ids" "private-subnets" {
  vpc_id = data.aws_vpc.jitsi-vpc.id
  filter {
    name   = "tag:Name"
    values = ["jitsi-private-*"]
  }
}

data "aws_subnet_ids" "public-subnets" {
  vpc_id = no
  filter {
    name   = "tag:Name"
    values = ["jitsi-public-*"]
  }
}

output "jitsi-vpc" {
  value = data.aws_vpc.jitsi-vpc.id
}

output "private-subnets" {
  value = data.aws_subnet_ids.private-subnets.ids
}

output "public-subnets" {
  value = data.aws_subnet_ids.public-subnets.ids
}

# module "ecs" {
#    source = "./ecs"

#    cluster_name = ""
#    subnets = aws_subnet_ids.private-subnets.id
# }

