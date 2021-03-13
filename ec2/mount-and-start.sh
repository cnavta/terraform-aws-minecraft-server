#!/bin/bash
sudo blkid --probe --match-types xfs /dev/xvdf || sudo mkfs -t xfs /dev/xvdf
sudo mkdir /data
sudo mount /dev/xvdf /data
sudo docker run -d -it -v /data:/data -e EULA=TRUE -e WHITE_LIST_USERS="Gonj,Paper2412,Starlight1814" -p 19132:19132/udp itzg/minecraft-bedrock-server
sleep 10