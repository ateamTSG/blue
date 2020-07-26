#!/bin/bash
#			    #
# Blue POC		    #
# TzahiA & LiorH 23/07/2020 #
#	RocketChat	    #
#############################

rm -f '/tmp/1.lock'
OC=$(which oc)
CR='bluewhalecr.azurecr.io'
PROJ='rocketchat-example'

# Start mongo DB
$OC new-app -n $PROJ --name=db $CR/mongo_custom:latest -l app=mongo
sleep 5

# Update PV 
$OC set volume -n $PROJ "dc/db" --add --overwrite --name='db-volume-2' --type='persistentVolumeClaim' --claim-name='mongodb-claim2' --mount-path='/data/db'
$OC set volume -n $PROJ "dc/db" --add --overwrite --name='db-volume-1' --type='persistentVolumeClaim' --claim-name='mongodb-claim' --mount-path='/data/configdb'
sleep 2

# Delete old pod
OLD_POD=`$OC get -n $PROJ pods -o custom-columns='POD:.metadata.name' --no-headers -l app=mongo| head -1`
$OC delete -n $PROJ pod/$OLD_POD

## 
touch /tmp/1.lock
while [ -f /tmp/1.lock ]
do
	  sleep 10 
	  $OC get pods | grep db | grep ContainerCreating
	  if [ $? -ne 0 ]
	  then
		rm -f /tmp/1.lock
	  fi
done

# Initiating ReplicaSet
DB_POD=`$OC get -n $PROJ pods -o custom-columns='POD:.metadata.name' --no-headers -l app=mongo | tail -1`
$OC exec -n $PROJ $DB_POD -i -t -- mongo --eval 'printjson(rs.initiate())'
$OC rsh -n $PROJ $DB_POD mongo --eval "printjson(cfg = rs.conf());printjson(cfg.members[0].host = \"$DB_POD:27017\");printjson(rs.reconfig(cfg, {force:true}))"
sleep 5

# Start RocketChat App
$OC new-app -n $PROJ --name=app $CR/rocketchat:latest -l app=rc -e ROOT_URL=http://localhost -e MONGO_OPLOG_URL=mongodb://db:27017/local

# Exposing the RC route URL
$OC expose -n $PROJ svc/app
sleep 5
echo "-------------------------------------------------------"
echo "Connect to URL: `$OC get -n $PROJ route | awk 'NR==2{print $2}'`"
echo "-------------------------------------------------------"


# For full CD process:
# $OC set triggers dc/<name> --auto
# Scale the App to 3
#$OC scale dc/app --replicas=3
