variable "project" {
  default = "terraform_practice"
}
variable "vpc_cidr" {
  default = "10.0.0.0/8"
}
variable "public_cidr" {
  default = ["10.1.0.0/16", "10.2.0.0/16"]
}
