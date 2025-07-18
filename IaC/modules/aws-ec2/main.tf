resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
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

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "bitcoin_ingestor" {
  ami                    = "ami-0150ccaf51ab55a51"
  instance_type          = "t2.nano"
  iam_instance_profile   = var.instance_profile_name
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name             = var.key_name

user_data = <<-EOF
#!/bin/bash
set -e
exec > /home/ec2-user/setup.log 2>&1

echo "=== Início da configuração $(date) ==="

# Atualizar pacotes e instalar dependências
yum update -y
yum install -y python3 python3-pip git

# Criar diretório de trabalho
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Criar requirements.txt
cat > requirements.txt << 'REQUIREMENTS'
${file("${path.module}/../../scripts/stream-script-folder/requirements.txt")}
REQUIREMENTS

# Criar main.py com auto-instalação de dependências
cat > main.py << 'MAINPY'
${file("${path.module}/../../scripts/stream-script-folder/main.py")}
MAINPY

# Criar .env
cat > .env << 'ENVFILE'
${file("${path.module}/../../scripts/stream-script-folder/.env.stream")}
ENVFILE

# Dar permissões corretas
chown -R ec2-user:ec2-user /home/ec2-user/app
chmod +x /home/ec2-user/app/main.py

# Criar serviço systemd
cat > /etc/systemd/system/bitcoin-stream.service << 'SERVICE'
[Unit]
Description=Bitcoin Firehose Ingestor
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/bin/python3 /home/ec2-user/app/main.py
Restart=on-failure
RestartSec=10
StandardOutput=append:/home/ec2-user/app/log.txt
StandardError=append:/home/ec2-user/app/error.txt

[Install]
WantedBy=multi-user.target
SERVICE

# Ativar e iniciar o serviço
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable bitcoin-stream.service
systemctl start bitcoin-stream.service

echo "=== Fim da configuração $(date) ==="
EOF

  tags = {
    Name = "firehose-ingestor"
  }
}
