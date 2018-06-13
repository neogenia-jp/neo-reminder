#!/bin/bash

/etc/init.d/ssh start

if [ -n "$TEST" ]; then
  exec bash -c 'for i in /mnt/blackbox_test/*; do ROUTE=$TEST ruby $i; done'
fi

bash /mnt/xml_rpc_server/start_server.sh $RPC_SERVER_PORT

echo '----- STARTED -----'

tail -f /var/log/xml_rpc_server.log

