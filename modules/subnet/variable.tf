variable "vpc_id" {
  description = "ID of the VPC to which the Subnet will be associated"
  type        = string
}
variable "subnet_cidr" {
  description = "CIDR block for the Subnet"
  type        = string
}
variable "subnet_name" {
  description = "Name tag for the Subnet"
  type        = string
}
variable "availability_zone" {
  description = "Availability Zone for the Subnet"
  type        = string
}

variable "tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
}