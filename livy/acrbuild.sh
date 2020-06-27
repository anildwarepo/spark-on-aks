#!/bin/bash
CONTAINER_REGISTRY=<your container registry name>
az acr build -t $CONTAINER_REGISTRY/livy:2.0 -r $CONTAINER_REGISTRY .