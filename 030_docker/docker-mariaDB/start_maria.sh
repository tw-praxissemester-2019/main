#!/bin/bash
# author: TWilts
# purpose: create mariaDB container 
dir=$(pwd)

### start mariadb container, mount datafolder in container, open port 3306
docker run --name mariaDB -e MYSQL_ROOT_PASSWORD=mariapw -d -t -v $dir/030_docker/docker-mariaDB/data:/var/lib/mysql -p 3306:3306 mariadb:latest
