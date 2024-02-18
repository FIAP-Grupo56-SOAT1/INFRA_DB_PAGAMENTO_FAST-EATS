terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
  }

  backend "s3" {
    bucket = "bucket-fiap56-to-remote-state"
    key    = "aws-rds-pagamento-fiap56/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

#create a security group for RDS Database Instance
resource "aws_security_group" "rds_pagamento_sg" {
  name = "rds_pagamento_sg"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_instance" "pagamento" {

  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_name                 = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["dbname"]
  username                = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["username"]
  password                = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["password"]
  port                    = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["port"]
  identifier              = var.identifier
  parameter_group_name    = var.parameter_group_name
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = true
  vpc_security_group_ids  = [aws_security_group.rds_pagamento_sg.id]
  backup_retention_period = 0
}

data "aws_secretsmanager_secret" "mysql" {
  name = "prod/soat1grupo56/MySQLPagamento"
}

data "aws_secretsmanager_secret_version" "mysql_credentials" {
  secret_id = data.aws_secretsmanager_secret.mysql.id
}

