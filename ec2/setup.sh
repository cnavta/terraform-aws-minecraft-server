#!/bin/bash
sudo yum install docker
docker run -d -it -e EULA=TRUE -p 19132:19132/udp itzg/minecraft-bedrock-server