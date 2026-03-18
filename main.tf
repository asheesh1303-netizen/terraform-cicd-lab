resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "ci-cd-vpc"
  }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = lookup(var.public_subnet, "us-east-1a")
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
      Name = "ci-cd-public-subnet"
    }
}

resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "ci-cd-ig"
    }
  
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    route {
      cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }
    tags = {
      Name = "ci-cd-public-rt"
    }
}   

resource "aws_route_table_association" "public_rta" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "sg" {
    name = "ci-cd-sg"
    description = "Security group for CI/CD instance"
    vpc_id = aws_vpc.main.id

    dynamic "ingress" {
      for_each = var.ports
      content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
        
        }
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "ci-cd-sg"
    }
}

resource "aws_key_pair" "key-tf" {
  key_name   = "key-tf"
  public_key = file("${path.module}/id-rsa.pub")


}

  


resource "aws_instance" "ci_cd_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.sg.id]
    tags = {
      Name = "ci-cd-instance"
    }
}

output "instance_public_ip" {
    value = aws_instance.ci_cd_instance.public_ip
}

output "instance_id" {
    value = aws_instance.ci_cd_instance.id
}

