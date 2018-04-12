#!/bin/bash

/etc/init.d/ssh start

if [ -n "$TEST" ]; then
  exec bash -c 'ROUTE=$TEST ruby /mnt/blackbox_test/test_v1.rb'
fi

bash /mnt/xml_rpc_server/start_server.sh $RPC_SERVER_PORT

echo '----- STARTED -----'

tail -f /var/log/xml_rpc_server.log

