
variable "load_balancer_name" {
  description = "Nome do Application Load Balancer"
  type        = string
  default     = "terraform-alb"
}

variable "subnet_ids" {
  description = "IDs das subnets onde o ALB será provisionado"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security Groups associados ao ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID da VPC utilizada pelo Target Group"
  type        = string
}

variable "instance_id" {
  description = "ID da instância EC2 associada ao Target Group"
  type        = string
}

variable "target_port" {
  description = "Porta em que a aplicação da EC2 recebe requisições"
  type        = number
  default     = 80
}
