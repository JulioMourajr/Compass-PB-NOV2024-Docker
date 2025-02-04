#!/bin/bash

sudo su

cd /home/ec2-user

sudo yum update -y

sudo yum install -y docker

sudo systemctl enable docker

sudo systemctl start docker

sudo usermod -aG docker ec2-user

sudo curl -SL https://github.com/docker/compose/releases/download/v2.32.4/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

sudo yum install -y nfs-utils

sudo mkdir -p /mnt/efs/wordpress

sudo chmod -R 777 /mnt/efs

echo "dns do efs:/ /mnt/efs nfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

sudo mount -a  

cd /home/ec2-user

cat <<EOL > /home/ec2-user/docker-compose.yaml
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    restart: always
    volumes:
      - /mnt/efs/wordpress:/var/www/html  # Monta os arquivos do WordPress no EFS
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: "endpoint do banco de dados"
      WORDPRESS_DB_USER: "admin"
      WORDPRESS_DB_PASSWORD: "suasenha"
      WORDPRESS_DB_NAME: "wordpressdb"
EOL

docker-compose -f /home/ec2-user/docker-compose.yaml up -d

