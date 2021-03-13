#!/bin/bash
sudo yum -y install docker
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl enable containerd.service
sudo systemctl start containerd.service
sleep 30
sudo docker run -d -it -e EULA=TRUE -e WHITE_LIST_USERS="Gonj,Paper2412,Starlight1814" -p 19132:19132/udp itzg/minecraft-bedrock-server
sleep 30