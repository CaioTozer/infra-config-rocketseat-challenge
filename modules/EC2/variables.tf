variable "ami_id" {
  description = "ID da AMI utilizada pela instância EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "ID da subnet onde a instância será provisionada"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de IDs dos Security Groups associados à instância"
  type        = list(string)
}

variable "instance_name" {
  description = "Nome da instância EC2"
  type        = string
  default     = "terraform-ec2"
}