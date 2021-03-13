resource "aws_eip" "minecraft-ip" {
  vpc = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "minecraft-vpc"
  cidr = "10.0.0.0/16"
  azs = ["us-west-2a"]

  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  external_nat_ip_ids = [aws_eip.minecraft-ip.id]

  tags = {
    Terraform = "true"
  }
}

resource "aws_ebs_volume" "minecraft-data-volume" {
  availability_zone = "us-west-2"
  size = 10
}

resource "aws_security_group" "minecraft-security-group" {
  name = "minecraft-security-group"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    description = "ssh"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 19132
    protocol = "udp"
    to_port = 19132
    description = "Minecraft"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "minecraft-key" {
  key_name = "minecraft-key"
  public_key = file("./minecraft-server.pub")
}

resource "aws_instance" "minecraftr-ec2" {
  ami = "ami-00f9f4069d04c0c6e"
  instance_type = "m3.large"
  subnet_id = module.vpc.public_subnets[0]
  key_name = "minecraft-key"
  security_groups = [aws_security_group.minecraft-security-group.id]

  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = var.minecraft_private_key
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "/tmp/setup.sh",
    ]

    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = var.minecraft_private_key
    }
  }
}

resource "aws_eip_association" "minecraft-ip-assoc" {
  instance_id = aws_instance.minecraftr-ec2.id
  allocation_id = aws_eip.minecraft-ip.id
}

resource "aws_volume_attachment" "minecraft-volume-att" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.minecraftr-ec2.id
  volume_id = aws_ebs_volume.minecraft-data-volume.id
}

resource "aws_route53_record" "minecraft_domain_assoc" {
  name = "minecraft.ix-n.com"
  type = "A"
  ttl = 300
  zone_id = "Z1S38SZN5Q68MB"
  records = [aws_eip.minecraft-ip.public_ip]
}

output "external-ip" {
  value = aws_eip.minecraft-ip.public_ip
}