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

resource "aws_default_vpc" "default_vpc" {
}

#create a security group for RDS Database Instance
resource "aws_security_group" "rds_sg" {
  vpc_id        = aws_default_vpc.default_vpc.id
  name = "rds_bd_${var.nome-db-servico}_sg"
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
  tags = {
    Name = "rds_${var.nome-db-servico}_sg"
  }
}

# Provide references to your default subnets
resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1b
  availability_zone = "us-east-1b"
}

#resource "aws_default_subnet" "default_subnet_c" {
#  # Use your own region here but reference to subnet 1b
#  availability_zone = "us-east-1c"
#}

resource "aws_db_subnet_group" "feasteats_db_subnet_group" {
  name = "feasteats-${var.nome-db-servico}-db-subnet-group"
  #subnet_ids = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
  subnet_ids = [aws_default_subnet.default_subnet_a.id,aws_default_subnet.default_subnet_b.id]
  tags = {
    Name = "feasteats-${var.nome-db-servico}-db-subnet-group"
  }
}



resource "aws_db_instance" "msyql_rds" {

  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_name                 = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["dbname"]
  username                = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["username"]
  password                = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["password"]
  port                    = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["port"]
  identifier              = var.identifier
  parameter_group_name    = var.parameter_group_name
  db_subnet_group_name    = aws_db_subnet_group.feasteats_db_subnet_group.name
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = var.publicly_accessible
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  backup_retention_period = var.backup_retention_period
  multi_az = false
}

data "aws_secretsmanager_secret" "mysql" {
  name = "prod/soat1grupo56/Pagamento"
}

data "aws_secretsmanager_secret_version" "mysql_credentials" {
  secret_id = data.aws_secretsmanager_secret.mysql.id
}

