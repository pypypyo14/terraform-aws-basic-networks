variable "project" {
  default = "terraform_practice"
}
variable "vpc_cidr" {
  default = "10.20.0.0/16"
}
variable "public_cidr" {
  default = ["10.20.0.0/20", "10.20.16.0/20"]
}

variable "private_cidr" {
  default = ["10.20.48.0/20", "10.20.64.0/20"]
}
