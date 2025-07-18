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

resource "aws_instance" "bitcoin_ingestor" {
  ami                  = "ami-0150ccaf51ab55a51"
  instance_type        = "t2.nano"
  iam_instance_profile = var.instance_profile_name
  subnet_id            = aws_subnet.public-subnet.id

  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y python3 pip git

# Create requirements.txt
cat > /home/ec2-user/requirements.txt << 'REQUIREMENTS'
${file("${path.module}/../../scripts/stream-script-folder/requirements.txt")}
REQUIREMENTS

# Install requirements
pip3 install -r /home/ec2-user/requirements.txt

# Create main.py
cat > /home/ec2-user/main.py << 'MAINPY'
${file("${path.module}/../../scripts/stream-script-folder/main.py")}
MAINPY

chmod +x /home/ec2-user/main.py

# Run the script
nohup python3 /home/ec2-user/main.py > /home/ec2-user/log.txt 2>&1 &
EOF

  tags = {
    Name = "firehose-ingestor"
  }
}