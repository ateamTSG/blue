#!/bin/bash


PROJ='hello-demo'

# Delete old deployment
#oc adm prune deployments -n $PROJ --keep-complete=3 --keep-failed=0 --confirm
oc adm prune deployments --all --keep-complete=3 --keep-failed=0

# Keeping last 3 versions of images
oc adm prune images --keep-tag-revisions=3 
