# spark-on-aks
This repo can be used to run spark jobs, spark streaming on Azure Kubernetes Service. 
Here are the key capabilities it provides
- Uses Spark 3.0.0 and Hadoop 3.2.1
- Integrates Azure Data Lake Storage Gen2 with Azure Kubernetes Services
- Spark jobs, spark streaming and delta can be used on AKS and read and write data to Azure Data Lake Gen2
- Multinode pools can be used in AKS
- Spot instance node pools can be used in AKS to run spark executors
- Livy end point can be used to submit jobs

[This repo](https://github.com/anildwarepo/nyctaxiaggregation) uses a sample java application that can be used to test spark-submit. This sample java application read from Azure Data Lake Storage and aggregates available NYC taxi data files and writes summary to Azure Data Lake Storage.


## Pre-requisites

- Azure Subscription
- Create Azure Service Principal using - az ad sp create-for-rbac
- Azure CLI
- kubectl CLI
- clone this repository
- Azure Data Lake account with NYC taxi data uploaded to test spark-submit
- Build [this repo](https://github.com/anildwarepo/nyctaxiaggregation) and upload to ADLS Gen2 container
- [TLC Trip Record Data](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

## 3 Steps to getting started

### Step 1
Update Azure parameters in aks/create-aks-aad-nodepool.sh.
You can modify other parameters such as VM size, VNet configuration etc.

        SSH_PUBLIC_KEY="your ssh public key"
        SUBCRIPTION_ID="your subscription id"
        RESOURCE_GROUP="your resource group"
        VNET_NAME="your vnet name"
        SUBNET_NAME="your subnet name"
        SERVICE_PRINCIPAL="your service principal guid"
        SERVICE_PRINCIPAL_SECRET="your service principal secret"

Provision AKS cluster.


        aks/create-aks-aad-nodepool.sh

Add node pool with spot instance.

        aks/add-aks-nodepool-spot.sh

Configure kubectl and attach Azure Container Registry to AKS Cluster. Attaching ACR to AKS will enable AKS to authenticate to ACR to pull container images.

        RESOURCE_GROUP="your resource group"
        AKS_CLUSTER_NAME="AKS Cluster Name"
        ACR_NAME="ACR Name"
        az aks get-credentials --name $AKS_CLUSTER_NAME -g $RESOURCE_GROUP --admin
        kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
        az aks update -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP --attach-acr $ACR_NAME

### Step 2
Create spark docker image and push it to ACR.

        spark/acrbuild.sh

Create spark namespace, role and rolebinding

        kubectl apply -f spark/spark-rbac.yaml


### Step 3 - Option 1
Modify parameters such as ADLS Gen2 container names, jar files names etc. in spark/test-spark-submit.sh.
Submit spark job. 

        kubectl proxy
        spark/test-spark-submit.sh


### Step 3 - Option 2
Livy can be used to submit spark jobs.
Update parameters in livy/acrbuild.sh.
Build livy docker container and push it to Azure Container Registry.


        livy/acrbuild.sh

Deploy livy server to AKS. This deploys a public accessible endpoint that can be used to post spark jobs. Modify deploy.yaml to deploy with internal ip address.

        kubectl apply -f livy/deploy.yaml


Use postman to post spark jobs using Livy Rest APIs. Modify json payload as required. 

        HTTP POST http://livy-ipaddress:8998/batches

        {
        "name": "NycTaxiData18",
        "className": "org.anildwa.spark.NycTaxiData",
        "numExecutors": 2,
        "driverMemory": "4g",
        "executorMemory": "20g",
        "executorCores": 6,
        "conf": {
                "spark.executor.instances" : 2, 
                "spark.eventLog.enabled" : "true", 
                "spark.eventLog.dir" :"abfss://spark-event-logs@<storageaccount>.dfs.core.windows.net/logs",  
                "spark.kubernetes.driver.volumes.hostPath.aksvm.mount.path" : "/mnt", 
                "spark.kubernetes.driver.volumes.hostPath.aksvm.options.path" : "/tmp",  
                "spark.kubernetes.namespace" : "spark",  
                "spark.kubernetes.authenticate.driver.serviceAccountName" : "spark-sa", 
                "spark.kubernetes.executor.podTemplateFile" : "/opt/livy/work-dir/executor-pod-template.yaml",
                "spark.kubernetes.container.image" : "<youracr>.azurecr.io/<yoursparkimage:tag>",
                "spark.kubernetes.container.image.pullPolicy" :"Always",
                "spark.hadoop.fs.azure.account.key.<storageaccount>.dfs.core.windows.net" : "<storage access key>"
        },
        "file": "abfss://jars@<storageaccount>.dfs.core.windows.net/drop/nyctaxidata-1.0.jar",
        "args": ["abfss://nytaxidata@<storageaccount>.dfs.core.windows.net/input", "abfss://nytaxidata@<storageaccount>.dfs.core.windows.net/output"]
        }


     