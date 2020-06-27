# spark-on-aks
This repo can be used to run spark jobs, spark streaming on Azure Kubernetes Service. 
Here are the key capabilities it provides
- Uses Spark 3.0.0 and Hadoop 3.2.1
- Integrates Azure Data Lake Storage Gen2 with Azure Kubernetes Services
- Spark jobs, spark streaming and delta can be used on AKS and read and write data to Azure Data Lake Gen2
- Multinode pools can be used in AKS
- Spot instance node pools can be used in AKS to run spark executors
- Livy end point can be used to submit jobs

## Pre-requisites

- Azure Subscription
- Create Azure Service Principal using - az ad sp create-for-rbac
- Azure CLI
- kubectl CLI
- clone this repository

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

