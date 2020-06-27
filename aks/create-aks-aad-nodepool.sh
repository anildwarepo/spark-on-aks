#! /bin/bash

SSH_PUBLIC_KEY="your ssh public key"
SUBCRIPTION_ID="your subscription id"
RESOURCE_GROUP="your resource group"
VNET_NAME="your vnet name"
SUBNET_NAME="your subnet name"
SERVICE_PRINCIPAL="your service principal guid"
SERVICE_PRINCIPAL_SECRET="your service principal secret"
AKS_CLUSTER_NAME="AKS Cluster Name"

az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --enable-vmss \
    --node-count 1 \
    -s Standard_B2ms \
    --ssh-key-value $SSH_PUBLIC_KEY  \
    --network-plugin azure \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip 10.0.0.10 \
    --docker-bridge-address 172.17.0.1/16 \
    --vnet-subnet-id /subscriptions/$SUBCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME \
    --service-principal $SERVICE_PRINCIPAL \
    --client-secret $SERVICE_PRINCIPAL_SECRET
