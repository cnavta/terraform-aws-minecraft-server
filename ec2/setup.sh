#!/bin/bash
sudo yum -y install docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
docker run -d -it -e EULA=TRUE -p 19132:19132/udp itzg/minecraft-bedrock-server