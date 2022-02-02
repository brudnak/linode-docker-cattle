#!/bin/sh

sudo apt update

sudo apt install -y docker.io

docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher:v2.6-head
