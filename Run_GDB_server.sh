#!/usr/bin/bash
HOST=" 172.16.0.44"
ssh $HOST "sudo docker exec vrouter_vrouter-agent_1 /var/log/contrail/gdb/bin/gdbserver :2023 /usr/bin/contrail-vrouter-agent"

