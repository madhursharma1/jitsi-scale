variable "cluster_name" {}
variable "subnets" {}
variable "alb_target_group" {}
variable "alb_security_group" {
    type = string
}
variable "vpc" {}