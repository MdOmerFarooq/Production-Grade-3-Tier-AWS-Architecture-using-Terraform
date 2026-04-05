variable "vpc_cidr" {
  type = string
}
variable "region" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}
