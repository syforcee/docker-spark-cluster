# Docker local Spark setup

## Spark config
Configuration requires providing compatible Spark and Hadoop version separately ([Spark: Hadoop free build](https://spark.apache.org/docs/latest/hadoop-provided.html)) enabling greater customization.
Default config is based on `Spark v3.1.3` and compatible `Hadoop v3.2.1`. Versions can be changed in Dockerfile variables.
```sh
ENV SPARK_VERSION=3.1.2 \
    HADOOP_VERSION=3.2.1
```
Currently cluster was tested only in `client` mode.

## Docker setup
Docker-compose is used for creating 3 connected node cluster: 1 master and 2 worker nodes.
Single Dockerfile is used for both master and worker nodes. Node's role is specified using `$SPARK_WORKLOAD` variable set in compose file.  
`apps` and `data` folders are mounted to the cluster with docker volumes:

Host Mount|Container Mount|Purposse
---|---|---
apps|/opt/spark-apps|Used to make available your app's jars on all workers & master
data|/opt/spark-data| Used to make available your app's data on all workers & master

Docker-compose exposes following ports of the cluster:
container|Exposed ports
---|---
spark-master|9090 7077
spark-worker-1|9091
spark-worker-2|9092

## Step by step:

1. Build Docker image
```sh
docker build -t cluster-spark:1.0 .
```

2. Run the docker-compose
```sh
docker-compose up -d
```

3. Submitting jobs
   Place your jar file in `apps`. Go into any cluster node console.
```sh
/opt/spark/bin/spark-submit --master spark://spark-master:7077 \
--jars *path-to-your-jar*.jar \
*jar-entry-point*
```

## Sources
https://github.com/mvillarrealb/docker-spark-cluster
