#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM openjdk:8-jdk-slim

ARG spark_uid=185

# Before building the docker image, first build and make a Spark distribution following
# the instructions in http://spark.apache.org/docs/latest/building-spark.html.
# If this docker file is being used in the context of building your images from a Spark
# distribution, the docker build command should be invoked from the top level directory
# of the Spark distribution. E.g.:
# docker build -t spark:latest -f kubernetes/dockerfiles/spark/Dockerfile .

RUN set -ex && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y bash tini libc6 libpam-modules krb5-user libnss3 wget && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/hadoop && \
    mkdir -p /opt/spark/examples && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/*

# Download Spark and Hadoop Binaries
RUN wget https://downloads.apache.org/spark/spark-3.0.0/spark-3.0.0-bin-hadoop3.2.tgz

# Extract tar all to path. Exclude certain files to reduce docker build time and container size
RUN tar -xzvf spark-3.0.0-bin-hadoop3.2.tgz -C /opt/spark/ --strip-components 1

RUN wget -P /opt/spark/jars/ https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-azure/3.2.1/hadoop-azure-3.2.1.jar
RUN wget -P /opt/spark/jars/ https://repo1.maven.org/maven2/org/wildfly/openssl/wildfly-openssl/1.0.9.Final/wildfly-openssl-1.0.9.Final.jar


# Clean up tar ball
RUN rm spark-3.0.0-bin-hadoop3.2.tgz


ENV SPARK_HOME /opt/spark
ENV PATH="$SPARK_HOME/bin:$PATH"


WORKDIR /opt/spark/work-dir
COPY executor-pod-template.yaml .
COPY driver-pod-template.yaml .
RUN chmod g+w /opt/spark/work-dir

ENTRYPOINT [ "/opt/spark/kubernetes/dockerfiles/spark/entrypoint.sh" ]

# Specify the User that the actual main process will run as
USER ${spark_uid}