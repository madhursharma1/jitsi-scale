variable "cluster_name" {
    type = string
    default = "jitsi-cluster"
}

variable "alb_name" {
    type = string
    default = "jitsi-alb"
}

variable "asg_name" {
    type = string
    default = "jitsi-asg"
}

variable "desired_capacity" {
    type = string
    default = "1"
}

variable "min_size" {
    type = string
    default = "1"
}

variable "max_size" {
    type = string
    default = "1"
}
variable "lc_name" {
    default = "jitsi-lc"
}
variable "instance_type" {
    default = "m5.large"
}