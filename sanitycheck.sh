#!/bin/bash
### author: twilts
### purpose: sanity check for container

echo "######### SUPERPIPE: SANITY CHECKS #########"

names[0]="webserver"
names[1]="tf_serving"
names[2]="tf_master"
names[3]="pyserv"
names[4]="docker-spark-cluster_spark-worker_1"
names[5]="docker-spark-cluster_spark-master_1"
names[6]="docker-airflow_webserver_1"
names[7]="docker-airflow_postgres_1"
names[8]="mariaDB"

### check if all container are running
allrun=1
for i in "${names[@]}"
do
    ans=$(docker inspect -f '{{.State.Running}}' $i)
    if [ "$ans" != "true" ]
    then
        echo "Container $i is not running"
        allrun=0
    fi
done
if [ $allrun -eq 1 ]
then
    echo "All container running"
else
    echo "Not all container running as expected"
fi

### check if webservers are up
web_pyserv=$(docker exec pyserv ps aux | grep apache2 | head -n 1)
web_tf=$(docker exec tf_master ps aux | grep apache2 | head -n 1)
web_webser=$(docker exec webserver ps aux | grep apache2 | head -n 1)
web_spark=$(docker exec docker-spark-cluster_spark-master_1 ps aux | grep apache2 | head -n 1)

allweb=1
if [[ $web_pyserv != *"apache"* ]]; then
  echo "Webserver not running in pyserv"
  allweb=0
fi
if [[ $web_tf != *"apache"* ]]; then
  echo "Webserver not running in tf_master"
  allweb=0
fi
if [[ $web_webser != *"apache"* ]]; then
  echo "Webserver not running in lamp"
  allweb=0
fi
if [[ $web_spark != *"apache"* ]]; then
  echo "Webserver not running in lamp"
  allweb=0
fi

if [ $allweb -eq 1 ] 
then
    echo "All webserver running"
fi