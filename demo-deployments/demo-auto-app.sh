#!/bin/bash

## Setting defaults for Maintainence

## keep 3 last completed deploy
oc adm prune deployments --all --keep-complete=3 --keep-failed=0 --confirm

# Creating resources:
oc apply -f demo-proj.yaml    ## Creating Project
oc apply -f demo-rq.yaml      ## Project Quota
oc apply -f demo-limits.yaml  ## Project limits
oc apply -f azurecr-secret.yaml ## Connecting to azure container registry
oc apply -f demo-svc.yaml  ## adding the Service for 3000 port nodejs
oc apply -f demo-is.yaml  ## Creating ImageStream for the container registry
oc apply -f demo-dc2.yaml  ## Project Deployment Config with container limits
oc apply -f demo-hpa.yaml ## Horizenal pod autoscaler Conf 3~6

