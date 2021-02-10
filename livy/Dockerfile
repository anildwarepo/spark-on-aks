FROM openjdk:8-jdk-slim as build

ENV GITHUB_REPO     apache/incubator-livy
ENV GITHUB_BRANCH   master
RUN mkdir -p /usr/share/man/man1
RUN apt clean && apt update && apt -y install git maven python-pip r-base && \
    pip install --upgrade pip setuptools
RUN git clone -b ${GITHUB_BRANCH} https://github.com/${GITHUB_REPO}.git && \
    cd incubator-livy && \
    mvn -T 8 clean package -DskipTests=true && \
    cp assembly/target/apache-livy-0.8.0-incubating-SNAPSHOT-bin.zip /


FROM openjdk:8-jdk-slim

RUN set -ex && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y bash tini libc6 libpam-modules libnss3 wget unzip && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/hadoop && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/*

ARG LIVY_VERSION_ARG=0.8.0-incubating-SNAPSHOT

ENV BASE_IMAGE              $SPARK_BASE#$BASE_IMAGE
ENV LIVY_VERSION            $LIVY_VERSION_ARG
ENV LIVY_HOME               /opt/livy
ENV LIVY_CONF_DIR           $LIVY_HOME/conf
ENV PATH                    $LIVY_HOME/bin:${PATH}

COPY --from=build /apache-livy-${LIVY_VERSION}-bin.zip /apache-livy-${LIVY_VERSION}-bin.zip
ARG spark_uid=185
USER root


RUN unzip /apache-livy-${LIVY_VERSION}-bin.zip -d / && \
    mv /apache-livy-${LIVY_VERSION}-bin /opt/ && \
    rm -rf $LIVY_HOME && \
    ln -s /opt/apache-livy-${LIVY_VERSION}-bin $LIVY_HOME && \
    rm -f /apache-livy-${LIVY_VERSION}-bin.zip && \
    cp $LIVY_CONF_DIR/log4j.properties.template $LIVY_CONF_DIR/log4j.properties && \
    mkdir -p $LIVY_HOME/work-dir && \
    mkdir /var/log/livy && \
    ln -s /var/log/livy $LIVY_HOME/logs

# Download Spark Binaries
RUN wget https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz

# Extract tar all to path. Exclude certain files to reduce docker build time and container size
RUN tar -xzvf spark-3.0.1-bin-hadoop3.2.tgz -C /opt/spark/ --strip-components 1

# Clean up tar ball
RUN rm spark-3.0.1-bin-hadoop3.2.tgz

# Setup ENV
ENV SPARK_HOME /opt/spark
ENV PATH="$SPARK_HOME/bin:$PATH"

COPY conf/* $LIVY_CONF_DIR/
COPY entrypoint.sh /opt/entrypoint.sh


RUN chmod +x /opt/*.sh

#  8998 - Livy Server port
# 10000 - Livy RPC Server for Jupyter integration
EXPOSE 8998 10000

WORKDIR $LIVY_HOME/work-dir
COPY driver-pod-template.yaml $LIVY_HOME/work-dir
COPY executor-pod-template.yaml $LIVY_HOME/work-dir
ENTRYPOINT [ "/opt/entrypoint.sh" ]