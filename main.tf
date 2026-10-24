# ECDSA key with P384 elliptic curve

# RSA key of size 4096 bits

 resource "tls_private_key" "rsa-4096-example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "local_file" "private_key" {
  content  = tls_private_key.rsa-4096-example.private_key_pem
  filename = "${path.module}/terraform-ec2.pem"
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-ec2"
  public_key = tls_private_key.rsa-4096-example.public_key_openssh
}

 resource "aws_security_group" "allow_tls" {
  name        = "allow_web_and_ssh"
  description = "Allow Web and SSH traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "web" {
  ami                    = "ami-02a9cdd4e98bc3c78"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  user_data = file("${path.module}/init.sh")

  tags = {
    Name = "Nginx-Server"
  }
}