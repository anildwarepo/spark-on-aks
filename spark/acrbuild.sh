#!/bin/bash
CONTAINER_REGISTRY=<your container registry name>
az acr build -t $CONTAINER_REGISTRY/spark:2.4.5 -r $CONTAINER_REGISTRY .