resource "aws_s3_bucket" "public_data" {
  bucket = "my-company-public-bucket"
  acl    = "public-read"

  tags = {
    Name = "PublicBucket"
  }
}

resource "aws_security_group" "open_ssh" {
  name = "open-ssh-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from anywhere"
  }

  tags = {
    Name = "OpenSSH"
  }
}

resource "aws_db_instance" "main" {
  engine           = "mysql"
  password         = "hunter2!"
  storage_encrypted = false

  tags = {
    Name = "MainDB"
  }
}

resource "aws_ebs_volume" "data" {
  size      = 100
  encrypted = false

  tags = {
    Name = "DataVolume"
  }
}
