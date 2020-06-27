#!/bin/bash

az aks get-credentials --name anildwaaks -g aks --admin
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
az aks update -n anildwaaks -g aks --attach-acr anildwacontainerregistry
