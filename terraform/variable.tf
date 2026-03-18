variable "region" {
    type = string
  
}


variable "ami_id" {
    type = string
  
}

variable "instance_type" {
    type = string
  
}

variable "ports" {  
    type = list(number) 
  
}

variable "vpc_cidr" {
    type = string
  
}

variable "public_subnet" {
    type = map(string)
  
}