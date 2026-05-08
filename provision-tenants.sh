#!/bin/bash

TOTAL_TENANTS=50

for i in $(seq 1 $TOTAL_TENANTS)
do
  NAMESPACE="startup-tenant-$i"

  echo "Provisioning $NAMESPACE"

  kubectl create namespace $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

  kubectl apply -f k8s/deployment.yaml -n $NAMESPACE

  kubectl apply -f k8s/redis.yaml -n $NAMESPACE

done
