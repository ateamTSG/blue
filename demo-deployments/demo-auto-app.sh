#!/bin/bash

oc apply -f demo-proj.yaml
oc apply -f azurecr-secret.yaml
oc apply -f demo-svc.yaml
oc apply -f demo-is.yaml
oc apply -f demo-dc.yaml
oc apply -f demo-hpa.yaml
