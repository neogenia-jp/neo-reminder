#!/bin/bash

/etc/init.d/ssh start

bash /mnt/xml_rpc_server/start_server.sh $RPC_SERVER_PORT

echo '----- STARTED -----'

tail -f /var/log/xml_rpc_server.log

