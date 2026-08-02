# Configurar el proveedor AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
     backend "s3" {
    bucket         = "zoi-play-jenkins-tfstate-887540997584"
    key            = "jenkins/terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile = true
    encrypt        = true
   }
}

provider "aws" {
  region = var.aws_region
}

# Security Group existente (importado) - jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins"
  description = "launch-wizard-14 created 2026-07-20T12:59:23.022Z"
  vpc_id      = "vpc-09cbd75b4390f5a97"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Angular App
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube
  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins"
  }
}

# EC2 Instance existente (importada) - jenkins/sonarqube/angular server
resource "aws_instance" "jenkins_server" {
  ami                    = "ami-0303e2e4a29f041a3"
  instance_type          = "t3.medium"
  subnet_id              = "subnet-09728f3942bb3aa5a"
  key_name               = "jenkins"
  iam_instance_profile   = "training-ssm-cw"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  user_data                   = file("${path.module}/scripts/user_data.sh")
  user_data_replace_on_change = false

  tags = {
    Name  = "jenkins"
    owner = "pablo.duarte@zoi.tech"
  }
}
