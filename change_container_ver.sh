#!/usr/bin/bash

BUILD_SERVER=172.16.0.4

if [ $# -ne 2 ]
then
    echo "Wrong number of arguments. Usage"
    echo "change_container_ver.sh CUR_VER NEW_VER"
    echo "- CUR_VER is the name of the branch with the current version of OpenSDN (tf-dev-sandbox)"
    echo "- NEW_VER is the name of the docker container with the new version of OpenSDN"
    exit 1
fi

CUR_VER=$1
NEW_VER=$2

echo "Changing build container from current $CUR_VER to new $NEW_VER"

DOCK_CMD=`ssh root@$BUILD_SERVER "sudo docker ps -a | grep \"tf-dev-sandbox_$NEW_VER\""`
if [ "$DOCK_CMD" = "" ]
then
    echo "Cant find the \"NEW\" container for $NEW_VER version"
    exit 1
fi

DOCK_CMD=`ssh root@$BUILD_SERVER "sudo docker ps -a | grep \"tf-dev-sandbox\""`
if [ "$DOCK_CMD" = "" ]
then
    echo "Cant find the \"CUR\" container for $CUR_VER version"
    exit 1
fi

DOCK_CMD=`ssh root@$BUILD_SERVER "sudo docker ps -a | grep \"tf-dev-sandbox_$CUR_VER\""`
if [ "$DOCK_CMD" != "" ]
then
    echo "Container for the \"CUR\" $CUR_VER version already exists"
    exit 1
fi

# stop the current container
ssh root@$BUILD_SERVER "sudo docker stop tf-dev-sandbox"
ssh root@$BUILD_SERVER "sudo docker stop tf-dev-env-registry"

# stop the new container
ssh root@$BUILD_SERVER "sudo docker stop tf-dev-sandbox_$NEW_VER"
ssh root@$BUILD_SERVER "sudo docker stop tf-dev-env-registry_$NEW_VER"

# rename the current container
ssh root@$BUILD_SERVER "sudo docker rename tf-dev-sandbox tf-dev-sandbox_$CUR_VER"
ssh root@$BUILD_SERVER "sudo docker rename tf-dev-env-registry tf-dev-env-registry_$CUR_VER"

# rename the new container
ssh root@$BUILD_SERVER "sudo docker rename tf-dev-sandbox_$NEW_VER tf-dev-sandbox"
ssh root@$BUILD_SERVER "sudo docker rename tf-dev-env-registry_$NEW_VER tf-dev-env-registry"

# start the new container
ssh root@$BUILD_SERVER "sudo docker start tf-dev-sandbox"
ssh root@$BUILD_SERVER "sudo docker start tf-dev-env-registry"

#
#END-OF-FILE
#

