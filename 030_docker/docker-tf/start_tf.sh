#!/bin/bash
# author: TWilts
# purpose: start docker-tensorflow instance
dir=$(pwd)

### start tensorflow container for model training, mount data folder for scripts and html folder for REST api
#-p 1111:1111
echo "######### TENSORFLOW: STARTING CONTAINER #########"
docker run -it -d --name tf_master -p 4444:80 -v $dir/030_docker/docker-tf/data:/data -v $dir/030_docker/docker-tf/html:/var/www/html -v $dir/070_config:/config_data -v $dir/010_data:/grid_data tensorflow/tensorflow bash 
docker run -it -d --name tf_serving -p 8501:8501 -v $dir/030_docker/docker-tf/data/models:/models/boostedtree -e MODEL_NAME=boostedtree tensorflow/serving

echo "######### TENSORFLOW: INSTALLING PYTHON PACKAGES #########"
### install some python packages 
silent=$(docker exec tf_master pip install pandas -q && \
        docker exec tf_master pip install numpy -q && \
        docker exec tf_master pip install sklearn -q && \
        docker exec tf_master pip install sqlalchemy -q && \
        docker exec tf_master pip install pymysql -q && \
        docker exec tf_master pip install requests -q )

### install the webserver and php so that training can be triggered by REST api
echo "######### TENSORFLOW: INSTALLING WEBSERVER AND PHP #########"
silent=$(docker exec tf_master apt-get update -q && \
        docker exec tf_master apt-get install -y -q apache2)

### only chance to install php7 in this container is to
### install tzdata first and put it into noninteractive mode
### otherwise it will ask for geografic location during php installation
### timezone is irrelevant
docker exec tf_master export DEBIAN_FRONTEND=noninteractive 
docker exec tf_master ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime 
docker exec tf_master apt-get install -y -q tzdata 
docker exec tf_master dpkg-reconfigure --frontend noninteractive tzdata

### install php and start apache
silent=$(docker exec tf_master apt-get install -y -q php7.0 && \
        docker exec tf_master apt-get install -y -q libapache2-mod-php && \
        docker exec tf_master service apache2 start)
echo "######### TENSORFLOW: DONE #########"