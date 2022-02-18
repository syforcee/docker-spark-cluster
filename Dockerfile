FROM openjdk:11.0.11-jre-slim-buster as builder

ENV SPARK_VERSION=3.1.2 \
    HADOOP_VERSION=3.2.1

ENV SPARK_HOME="/opt/spark" \
    HADOOP_HOME="/opt/hadoop" \
    PATH="$SPARK_HOME/bin:$HADOOP_HOME/bin:$PATH"

RUN apt-get update && apt-get install -y wget

RUN wget --no-verbose -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz" \
    && mkdir -p $SPARK_HOME \
    && tar -xf apache-spark.tgz -C $SPARK_HOME --strip-components=1 \
    && rm apache-spark.tgz

RUN wget --no-verbose -O hadoop.tgz "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    && mkdir -p $HADOOP_HOME \
    && tar -xf hadoop.tgz -C $HADOOP_HOME --strip-components=1 \
    && rm hadoop.tgz

RUN echo "export SPARK_DIST_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)" >> $SPARK_HOME/conf/spark-env.sh

FROM builder as apache-spark

WORKDIR $SPARK_HOME

ENV SPARK_MASTER_PORT=7077 \
    SPARK_MASTER_WEBUI_PORT=8080 \
    SPARK_LOG_DIR=$SPARK_HOME/logs \
    SPARK_MASTER_LOG=$SPARK_HOME/logs/spark-master.out \
    SPARK_WORKER_LOG=$SPARK_HOME/logs/spark-worker.out \
    SPARK_WORKER_WEBUI_PORT=8080 \
    SPARK_WORKER_PORT=7000 \
    SPARK_MASTER="spark://spark-master:7077" \
    SPARK_WORKLOAD="master"

EXPOSE 8080 7077 7000

RUN mkdir -p $SPARK_LOG_DIR && \
    touch $SPARK_MASTER_LOG && \
    touch $SPARK_WORKER_LOG && \
    ln -sf /dev/stdout $SPARK_MASTER_LOG && \
    ln -sf /dev/stdout $SPARK_WORKER_LOG

COPY start-spark.sh /

CMD ["/bin/bash", "/start-spark.sh"]
