### author: twilts
### purpose: start all container of the pipeline

### get master ip (as in superpipe) because it could be changed
masterIP=0
if [ "$(uname)" == "Darwin" ]; then
    masterIP=$(ipconfig getifaddr en0)
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    masterIP=$(hostname -I)
fi

echo "############ STARTING CONTAINER ##############"

docker start tf_serving
sleep 3
docker start tf_master
sleep 3
docker start pyserv
sleep 3
docker start docker-spark-cluster_spark-worker_1
sleep 3
docker start docker-spark-cluster_spark-master_1
sleep 3
docker start docker-airflow_webserver_1
sleep 3
docker start docker-airflow_postgres_1
sleep 3
docker start mariaDB
sleep 3
docker start webserver
sleep 3

echo "############ WRITING IP ##############"

### write new ips into container (could be changed due to container restart)
docker exec docker-airflow_webserver_1 bash -c "echo $masterIP > /usr/local/airflow/ip"
ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariaDB)
docker exec docker-spark-cluster_spark-master_1 bash -c "echo $ip > /scripts/ip"
docker exec tf_master bash -c "echo $ip > /data/ip"
docker exec tf_master bash -c "echo $masterIP > /data/tfs_ip"

echo "############ RESTARTING WEBSERVER ##############"

### restart all webserver
docker exec pyserv service apache2 restart
docker exec tf_master service apache2 restart
docker exec docker-spark-cluster_spark-master_1 service apache2 restart

### do sanity check
bash sanitycheck.sh