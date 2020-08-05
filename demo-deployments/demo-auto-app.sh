#!/bin/bash
## Setting defaults for maintain
## keep 3 last completed deploy
oc adm prune deployments --all --keep-complete=3 --keep-failed=0

# Creating resources
oc apply -f demo-proj.yaml
oc apply -f azurecr-secret.yaml
oc apply -f demo-svc.yaml
oc apply -f demo-is.yaml
oc apply -f demo-dc.yaml
oc apply -f demo-hpa.yaml
