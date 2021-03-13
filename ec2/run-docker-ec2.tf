resource "aws_security_group" "minecraft-security-group" {
  name = "minecraft-security-group"
  ingress {
    from_port = 22
    protocol = "ssh"
    to_port = 22
  }
}

resource "aws_key_pair" "minecraft-key" {
  key_name = "minecraft-key"
  public_key = file("./minecraft-server.pub")
}

resource "aws_eip" "minecraft-ip" {
}

resource "aws_ebs_volume" "minecraft-storage" {
  availability_zone = "us-west-2a"
  size = 5
}

resource "aws_instance" "minecraftr-ec2" {
  ami = "ami-00f9f4069d04c0c6e"
  instance_type = "t2.micro"
  subnet_id = "subnet-0f7579a46c54b0142"
  key_name = "minecraft-key"
  security_groups = [aws_security_group.minecraft-security-group.id]

  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh",
    ]

    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
    }
  }
}

resource "aws_eip_association" "minecraft-ip-assoc" {
  instance_id = aws_instance.minecraftr-ec2.id
  network_interface_id = aws_eip.minecraft-ip.network_interface
}

resource "aws_volume_attachment" "minecraft-storage-att" {
  device_name = "/data"
  volume_id   = aws_ebs_volume.minecraft-storage.id
  instance_id = aws_instance.minecraftr-ec2.id
}


output "external-ip" {
  value = aws_eip.minecraft-ip.public_ip
}