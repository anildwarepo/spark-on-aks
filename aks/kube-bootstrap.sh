#!/bin/bash

RESOURCE_GROUP="your resource group"
AKS_CLUSTER_NAME="AKS Cluster Name"
ACR_NAME="ACR Name"
az aks get-credentials --name $AKS_CLUSTER_NAME -g $RESOURCE_GROUP --admin
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
az aks update -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP --attach-acr $ACR_NAME
