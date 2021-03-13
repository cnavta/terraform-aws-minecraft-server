#!/bin/bash

sudo yum -y install docker
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl enable containerd.service
sudo systemctl start containerd.service
sleep 10