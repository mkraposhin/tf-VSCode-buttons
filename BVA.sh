#!/usr/bin/bash
AGENT_HOSTS=" 172.16.0.38 172.16.0.44 172.16.0.34"
TARGET=debug

docker container exec -e CONTRAIL_COMPILE_WITHOUT_SYMBOLS=yes -w ~/work/tungsten/contrail tf-dev-sandbox scons -j16 --opt=$TARGET contrail-vrouter-agent
for TGT_HIP in $AGENT_HOSTS
do
    echo "Doing rsync $TGT_HIP and copying to /var/log/contrail"
    rsync --progress -a ./contrail-vrouter-agent-$TARGET $TGT_HIP:~/rsync_dir/contrail-vrouter-agent-$TARGET

    echo "copying to /usr/bin of agent $TGT_HIP docker"
    ssh $TGT_HIP "sudo docker container exec -w / vrouter_vrouter-agent_1 rm -rf /usr/bin/contrail-vrouter-agent"
    ssh $TGT_HIP "sudo docker cp ~/rsync_dir/contrail-vrouter-agent-$TARGET vrouter_vrouter-agent_1:/usr/bin/contrail-vrouter-agent"
    ssh $TGT_HIP "sudo docker container exec -w / vrouter_vrouter-agent_1 ls -lah /usr/bin/contrail-vrouter-agent"
done