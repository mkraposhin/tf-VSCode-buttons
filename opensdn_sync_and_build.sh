function check_input_parameters() {
    if [ "$OPENSDN_TARGET_TYPE" = "" ]
    then
        return 1
    fi
    if [ "$OPENSDN_N_BUILD_CPU" = "" ]
    then
        return 2
    fi
    if [ "$OPENSDN_TARGET_DIR" = "" ]
    then
        return 3
    fi
    if [ "$OPENSDN_TARGET_BIN" = "" ]
    then
        return 4
    fi
    if [ "$OPENSDN_TARGET_CONTAINER" = "" ]
    then
        return 5
    fi
    return 0
}

check_input_parameters
check_code=$?

if [ $check_code -ne 0 ]
then
    echo "Critical input parameter(s) was(were) not specified: $check_code"
    exit
fi

STARTED=`date`
if [ "$OPENSDN_BUILD_HOST" != "" ]
then
    echo "Syncing sources with remote build server $OPENSDN_BUILD_HOST"
    rsync -avt \
    --exclude '.sconsign.dblite' \
    --exclude '.sconf_temp' \
    --exclude '.stages' \
    --exclude 'BUILD' \
    --exclude 'BUILDROOT' \
    --exclude 'RPMS' \
    --exclude 'SOURCES' \
    --exclude 'SPECS' \
    --exclude 'SRPMS' \
    --exclude 'SRPMSBUILD' \
    --exclude 'build' \
    --exclude 'config.log' \
    contrail/ root@$OPENSDN_BUILD_HOST:/root/$OPENSDN_REMOTE_BUILD_DIR/contrail/
    rsync -avtu tf-dev-env/ root@$OPENSDN_BUILD_HOST:/root/$OPENSDN_REMOTE_BUILD_DIR/tf-dev-env
    echo "Running build on remote build server $OPENSDN_BUILD_HOST"
    #ssh root@$BUILD_HOST "docker container exec -e CONTRAIL_COMPILE_WITHOUT_SYMBOLS=yes -w /root/contrail tf-dev-sandbox scons -j$OPENSDN_N_BUILD_CPU --opt=$OPENSDN_TARGET_TYPE $OPENSDN_TARGET_BIN"
    ssh root@$OPENSDN_BUILD_HOST "docker container exec -w /root/contrail tf-dev-sandbox scons -j$OPENSDN_N_BUILD_CPU --opt=$OPENSDN_TARGET_TYPE $OPENSDN_TARGET_BIN"
else
    echo "Running build locally"
    docker container exec -w /root/contrail tf-dev-sandbox scons -j$OPENSDN_N_BUILD_CPU --opt=$OPENSDN_TARGET_TYPE $OPENSDN_TARGET_BIN
fi


echo "Copying binary $OPENSDN_TARGET_BIN from the container into the home directory"
if [ "$OPENSDN_BUILD_HOST" != "" ]
then
    ssh root@$OPENSDN_BUILD_HOST \
        "docker container cp \
        tf-dev-sandbox:/root/contrail/build/$OPENSDN_TARGET_TYPE/$OPENSDN_TARGET_DIR/$OPENSDN_TARGET_BIN \
        /root/$OPENSDN_REMOTE_BUILD_DIR/$OPENSDN_TARGET_BIN-$OPENSDN_TARGET_TYPE"
    rsync --progress -a \
        root@$OPENSDN_BUILD_HOST:/root/$OPENSDN_REMOTE_BUILD_DIR/$OPENSDN_TARGET_BIN-$OPENSDN_TARGET_TYPE \
        ./$OPENSDN_TARGET_BIN-$OPENSDN_TARGET_TYPE
else
        "docker container cp \
        tf-dev-sandbox:/root/contrail/build/$OPENSDN_TARGET_TYPE/$OPENSDN_TARGET_DIR/$OPENSDN_TARGET_BIN \
        ./$OPENSDN_TARGET_BIN-$OPENSDN_TARGET_TYPE"
fi

echo "Copying to target hosts"
for TGT_HIP in $OPENSDN_TARGET_HOSTS
do
    echo "Doing rsync with $TGT_HIP"
    ssh $TGT_HIP "ls ~/rsync_dir"
    if [ $? -ne 0 ]
    then
        ssh $TGT_HIP "mkdir ~/rsync_dir"
    fi
    rsync --progress -a ./$OPENSDN_TARGET_BIN-$OPENSDN_TARGET_TYPE $TGT_HIP:~/rsync_dir/$OPENSDN_TARGET_BIN-$OPENSDN_TARGET_TYPE

    echo "Copying to /usr/bin of binary $OPENSDN_TARGET_BIN-$OPENSDN_TARGET_TYPE into $TGT_HIP docker $OPENSDN_TARGET_CONTAINER"
    ssh $TGT_HIP "sudo docker container exec -w / $OPENSDN_TARGET_CONTAINER rm -rf /usr/bin/$OPENSDN_TARGET_BIN"
    ssh $TGT_HIP "sudo docker cp ~/rsync_dir/$OPENSDN_TARGET_BIN-$OPENSDN_TARGET_TYPE $OPENSDN_TARGET_CONTAINER:/usr/bin/$OPENSDN_TARGET_BIN"
    ssh $TGT_HIP "sudo docker container exec -w / $OPENSDN_TARGET_CONTAINER ls -lah /usr/bin/$OPENSDN_TARGET_BIN"
done

echo "Done"
FINISHED=`date`
echo "STARTED: $STARTED FINISHED: $FINISHED"

#
#END-OF-FILE
#
