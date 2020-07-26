#!/bin/bash

OC=$(which oc)

$OC new-app --name=db bluewhalecr.azurecr.io/mongo_custom:latest --as-test=true -l app=mongo
sleep 2
$OC new-app --name=app bluewhalecr.azurecr.io/rocket.chat:latest --as-test=true -l app=rc -e ROOT_URL=http://localhost -e MONGO_OPLOG_URL=mongodb://db:27017/local
sleep 15
DB_POD=`oc get pods -o custom-columns=POD:.metadata.name --no-headers -l app=mongo`
echo "db_pod_name=$DB_POD"
$OC exec $DB_POD -i -t -- mongo --eval 'printjson(rs.initiate())'
sleep 2
$OC expose svc/app
$OC scale dc/app --replicas=3
