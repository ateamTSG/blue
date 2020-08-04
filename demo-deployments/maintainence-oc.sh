#!/bin/bash


PROJ='hello-demo'

# Delete old deployment
oc adm prune deployments -n $PROJ --keep-complete=3 --keep-failed=0 --confirm
