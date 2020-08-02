#!/bin/bash

OC=$(which oc)
PROJ='blue-seal-project'

## Creating Secret to connect to Azure's Container registry
$OC create -n $PROJ -f secret-CR.yaml

## Creating Volumes

## Creating ImageStream
$OC create -n $PROJ -f imagestream-RC.yaml


# Deploying DB
## Creating Deployment Config
$OC create -n $PROJ -f deployment-db.yaml

$OC get pods -o name -l app=mongo | grep pod
if [ $? -ne 0 ]
then
	echo "Creating Pod"
	sleep 5
fi
# Getting the pod
DB_POD=`$OC get pods -o name -l app=mongo | awk -F'/' '{print $2}'`
# Waiting for container to Run
touch /tmp/db.lock
echo "Please wait while container starting..."
while [ -f /tmp/db.lock ]
do
          sleep 7
	  $OC get pods -l app=mongo | grep -w Running
          if [ $? -eq 0 ]
          then
                rm -f /tmp/db.lock
          fi
done
# Initializing MongoDB
$OC rsh -n $PROJ $DB_POD mongo --eval "printjson(rs.initiate());printjson(cfg = rs.conf());printjson(cfg.members[0].host = \"$DB_POD:27017\");printjson(rs.reconfig(cfg, {force:true}))"

# Deploying APP
$OC create -n $PROJ -f deployment-app.yaml

$OC get pods -o name -l app=rc | grep pod
if [ $? -ne 0 ]
then
        echo "Creating Pod"
        sleep 5
fi
# Getting the pod
# Waiting for container to Run
touch /tmp/app.lock
echo "Please wait while container starting..."
while [ -f /tmp/app.lock ]
do
          sleep 7
          $OC get pods -l app=rc | grep -w Running
          if [ $? -eq 0 ]
          then
                rm -f /tmp/app.lock
          fi
done
# Define autoScaler
oc autoscale dc/app --min 3 --max 6 --cpu-percent=90
# Exposing the RC route URL
$OC expose -n $PROJ svc/app
echo ""
echo "--------- Auto Deploy Script Done! --------------"
