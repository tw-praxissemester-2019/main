### author: twilts
### purpose: stop all container of the pipeline

docker stop webserver
docker stop tf_serving
docker stop tf_master
docker stop pyserv
docker stop docker-spark-cluster_spark-worker_1
docker stop docker-spark-cluster_spark-master_1
docker stop docker-airflow_webserver_1
docker stop docker-airflow_postgres_1
docker stop mariaDB
