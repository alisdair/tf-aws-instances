provider "aws" {
  region = "us-east-1"
}

variable "instance_count" {
  type    = number
}

variable "password_length" {
  type    = number
  default = 10
}

variable "tags" {
  type = map(string)
}

resource "aws_security_group" "allow_egress" {
  name = "allow_egress"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ingress_ssh" {
  name = "allow_ingress_ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = "ami-2757f631"
  instance_type = "t2.micro"

  security_groups = [
    aws_security_group.allow_ingress_ssh.name
  ]

  tags = var.tags

  provisioner "local-exec" {
    command = "echo 'IP address: ${self.private_ip}'"
  }

  provisioner "local-exec" {
    command = "sleep ${count.index * 10}"
  }
}

resource "random_password" "password" {
  length  = var.password_length
  special = false
}

resource "aws_db_instance" "example" {
  instance_class    = "db.t3.micro"
  allocated_storage = 64
  engine            = "mysql"
  username          = "someone"
  password          = random_password.password.result

 skip_final_snapshot = true
}
