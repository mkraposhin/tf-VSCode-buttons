#!/usr/bin/bash
ssh $OPENSDN_GDBSERVER_HOST \
    "sudo docker exec $OPENSDN_TARGET_CONTAINER \
    /var/log/contrail/gdb/bin/gdbserver :$OPENSDN_GDBSERVER_PORT \
    /usr/bin/$OPENSDN_TARGET_BIN"
