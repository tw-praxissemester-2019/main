echo "######### SUPERPIPE: ENVIRONMENT #########"
#conda update -y --prefix /anaconda3 anaconda
#conda create -y -n ml-pipe 
#conda install -y -n ml-pipe anaconda netcdf4 xarray gdal sqlite mysql-connector-python geopandas

#source /anaconda3/etc/profile.d/conda.sh 
#conda activate ml-pipe

echo "######### SUPERPIPE: CONFIG #########"
### get IP of host to use it in airflow (trigger model training)
masterIP=0
if [ "$(uname)" == "Darwin" ]; then
    masterIP=$(ipconfig getifaddr en0)
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    masterIP=$(hostname -I)
fi

echo "######### SUPERPIPE: PREPARING DATA #########"
#bash 040_bash/cutter.sh

echo "######### SUPERPIPE: MARIADB #########"
bash 030_docker/docker-mariaDB/start_maria.sh

echo "######### SUPERPIPE: AIRFLOW #########"
### a dockerbuild is done before to install mysql packages in python via pip.
### Alternative way would be to execute pip after container-creation, like with spark
docker build -q 030_docker/docker-airflow/ -t puckel/docker-airflow

### compose airflow container and connect it to the bridge network
docker-compose -f 030_docker/docker-airflow/docker-compose-LocalExecutor.yml up -d
docker network connect bridge docker-airflow_webserver_1
### write ip of host system into container. is needed to trigger training
docker exec docker-airflow_webserver_1 bash -c "echo $masterIP > /usr/local/airflow/ip"

echo "######### SUPERPIPE: SPARK #########"
### Build the spark images
bash 030_docker/docker-spark-cluster/build-images.sh
bash 030_docker/docker-spark-cluster/create_spark.sh

### write ip of mariaDB into spark master
ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariaDB)
docker exec docker-spark-cluster_spark-master_1 bash -c "echo $ip > /scripts/ip"
### start python container for serving the trained spark model
bash 030_docker/docker-python/start_pyserv.sh


echo "######### SUPERPIPE: TENSORFLOW #########"
### pull tensorflow and tf serving image and start container
docker pull tensorflow/tensorflow
docker pull tensorflow/serving
bash 030_docker/docker-tf/start_tf.sh
### write ip of mariadb container into master-tf. necessary for training
docker exec tf_master bash -c "echo $ip > /data/ip"
### write ip of master into tf container so that it cann call serving afterwards
docker exec tf_master bash -c "echo $masterIP > /data/tfs_ip"

echo "######### SUPERPIPE: APACHE WEBSERVER #########"
### pull fauria/lamp image
docker pull fauria/lamp
### run webserver
docker run -it -d -p 5555:80 --name "webserver" -v $(pwd)/030_docker/docker-lamp/html:/var/www/html fauria/lamp

### do sanity checks
#bash sanitycheck.sh

#2222 pyserve
#3333 sparkmaster
#4444 tensorflow
#5555 webserver
