
variable "vpc_name" {
  description = "Nome da VPC"
  type        = string
  default     = "terraform-vpc"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "Nome da subnet"
  type        = string
  default     = "terraform-subnet"
}

variable "subnet_cidr" {
  description = "Bloco CIDR da subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone onde a subnet será criada"
  type        = string
}
