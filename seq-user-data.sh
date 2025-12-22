#!/usr/bin/env bash
set -e
# updating system
yum update -y

# installing docker
yum install docker -y

# installing docker-compose
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
chmod -v +x /usr/local/bin/docker-compose

# activating docker
systemctl enable docker.service
systemctl start docker.service

# adding ec2-user to docker group
usermod -a -G docker ec2-user
newgrp docker # realoding group

# Download and run Seq image
docker run --name seq-server -d --restart unless-stopped -e ACCEPT_EULA=Y --mount type=bind,source=/data,target=/data -p 80:80 -p 5341:5341 datalust/seq:2025.2