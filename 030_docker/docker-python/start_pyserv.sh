#!/bin/bash
### author: twilts
### purpose: start docker container with python to serve for spark model
dir=$(pwd)

docker run -d -t -p 2222:80 --name pyserv -v $dir/030_docker/docker-spark-cluster/export/models:/models -v $dir/030_docker/docker-python/scripts:/scripts -v $dir/030_docker/docker-python/html:/var/www/html -v $dir/070_config:/config_data -v $dir/010_data:/grid_data python
### install pypmml to load the exported modell
docker exec pyserv pip install -q pypmml
docker exec pyserv pip install -q --upgrade git+https://github.com/autodeployai/pypmml.git
### numpy is needed by pypmmml 
docker exec pyserv pip install -q numpy
### install java, webserver and start it
silent=$(docker exec pyserv apt-get update && \
    docker exec pyserv apt-get install -y default-jdk && \
    docker exec pyserv apt-get install -y -q apache2 && \
    docker exec pyserv apt-get install -y -q php7.0 && \
    docker exec pyserv apt-get install -y php libapache2-mod-php && \
    docker exec pyserv a2enmod mpm_prefork && \
    docker exec pyserv a2enmod php7.3 && \
    docker exec pyserv service apache2 start)
