echo "Restarting service: $OPENSDN_TARGET_CONTAINER"
for TGT_HIP in $OPENSDN_TARGET_HOSTS
do
    # AGENT_PID=`ssh $TGT_HIP pgrep -fn contrail-vrouter-agent`
    # echo "Stopping agent $TGT_HIP $AGENT_PID"
    # ssh $TGT_HIP "sudo kill --signal 15 $AGENT_PID"
    echo "Restarting service on $TGT_HIP"
    ssh $TGT_HIP "sudo docker restart --time=1 $OPENSDN_TARGET_CONTAINER"
done

#
#END-OF-FILE
#
