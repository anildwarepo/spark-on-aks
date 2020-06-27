#!/bin/bash
 ./bin/spark-submit     \
 --class org.anildwa.spark.NycTaxiData \   
 --master k8s://http://127.0.0.1:8001/  \ 
 --deploy-mode cluster    \
 --num-executors 1     \
 --driver-memory 2g     \
 --executor-memory 2g     \
 --executor-cores 2     \
 --conf spark.executor.instances=1  \
 --conf spark.kubernetes.namespace=spark \
 --conf spark.kubernetes.executor.podTemplateFile=spark/executor-pod-template.yaml  \
 --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark-sa  \
 --conf spark.kubernetes.container.image=<acrname>.azurecr.io/spark-3.0.0:2.0 \
 --conf spark.hadoop.fs.azure.account.key.<storageaccount>.dfs.core.windows.net=<storage account access key>   \
 abfss://jars@<storageaccount>.dfs.core.windows.net/drop/nyctaxidata-1.0.jar \
 abfss://nytaxidata@<storageaccount>.dfs.core.windows.net/input \
 abfss://nytaxidata@<storageaccount>.dfs.core.windows.net/output