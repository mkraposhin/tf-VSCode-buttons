#!/usr/bin/bash

BUILD_SERVER=172.16.0.4

if [ $# -ne 3 ]
then
    echo "Wrong number of arguments. Usage"
    echo "change_container_ver.sh PREFIX CUR_VER NEW_VER"
    echo "- PREFIX is the prefix for tf-dev-sandbox container name"
    echo "- CUR_VER is the name of the branch with the current version of OpenSDN (tf-dev-sandbox)"
    echo "- NEW_VER is the name of the docker container with the new version of OpenSDN"
    exit 1
fi

PREFIX=$1
CUR_VER=$2
NEW_VER=$3

echo "Changing build container from current $CUR_VER to new $NEW_VER"

DOCK_CMD=`ssh root@$BUILD_SERVER "sudo docker ps -a | grep \"$PREFIX-tf-dev-sandbox_$NEW_VER\""`
if [ "$DOCK_CMD" = "" ]
then
    echo "Cant find the \"NEW\" container for $NEW_VER version"
    exit 1
fi

DOCK_CMD=`ssh root@$BUILD_SERVER "sudo docker ps -a | grep \"$PREFIX-tf-dev-sandbox\""`
if [ "$DOCK_CMD" = "" ]
then
    echo "Cant find the \"CUR\" container for $CUR_VER version"
    exit 1
fi

DOCK_CMD=`ssh root@$BUILD_SERVER "sudo docker ps -a | grep \"$PREFIX-tf-dev-sandbox_$CUR_VER\""`
if [ "$DOCK_CMD" != "" ]
then
    echo "Container for the \"CUR\" $CUR_VER version already exists"
    exit 1
fi

# stop the current container
ssh root@$BUILD_SERVER "sudo docker stop $PREFIX-tf-dev-sandbox"
ssh root@$BUILD_SERVER "sudo docker stop $PREFIX-tf-dev-env-registry"

# stop the new container
ssh root@$BUILD_SERVER "sudo docker stop $PREFIX-tf-dev-sandbox_$NEW_VER"
ssh root@$BUILD_SERVER "sudo docker stop $PREFIX-tf-dev-env-registry_$NEW_VER"

# rename the current container
ssh root@$BUILD_SERVER "sudo docker rename $PREFIX-tf-dev-sandbox tf-dev-sandbox_$CUR_VER"
ssh root@$BUILD_SERVER "sudo docker rename $PREFIX-tf-dev-env-registry tf-dev-env-registry_$CUR_VER"

# rename the new container
ssh root@$BUILD_SERVER "sudo docker rename $PREFIX-tf-dev-sandbox_$NEW_VER tf-dev-sandbox"
ssh root@$BUILD_SERVER "sudo docker rename $PREFIX-tf-dev-env-registry_$NEW_VER tf-dev-env-registry"

# start the new container
ssh root@$BUILD_SERVER "sudo docker start $PREFIX-tf-dev-sandbox"
ssh root@$BUILD_SERVER "sudo docker start $PREFIX-tf-dev-env-registry"

#
#END-OF-FILE
#

