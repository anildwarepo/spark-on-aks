#!/bin/bash
az aks nodepool add \
    --resource-group aks \
    --cluster-name anildwaaks \
    --name dedicated \
    --enable-cluster-autoscaler \
    --min-count 3 \
    --max-count 3 \
    -s Standard_D8s_v3 \
    --no-wait