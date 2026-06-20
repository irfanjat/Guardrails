resource "aws_s3_bucket" "private_data" {
  bucket = "my-company-private-bucket"
  acl    = "private"

  block_public_acls = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "PrivateBucket"
    CostCenter  = "12345"
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_security_group" "restricted_ssh" {
  name = "restricted-ssh-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "SSH from internal network only"
  }

  tags = {
    Name        = "RestrictedSSH"
    CostCenter  = "12345"
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_db_instance" "main" {
  engine           = "mysql"
  password         = var.db_password
  storage_encrypted = true

  tags = {
    Name        = "MainDB"
    CostCenter  = "12345"
    Environment = "production"
    Owner       = "platform-team"
  }
}

resource "aws_ebs_volume" "data" {
  size      = 100
  encrypted = true

  tags = {
    Name        = "DataVolume"
    CostCenter  = "12345"
    Environment = "production"
    Owner       = "platform-team"
  }
}

variable "db_password" {
  description = "Database password, provided via CI/CD secret"
  type        = string
  sensitive   = true
}
