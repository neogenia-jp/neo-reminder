#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

export RPC_SERVER_PORT=$1

ruby $SCRIPT_DIR/server.rb >> /var/log/xml_rpc_server.log 2>&1 &

PID=$!

echo "XML RPC Server was started. port=$RPC_SERVER_PORT PID=$PID"

echo $PID > /var/run/xml_rpc_server.pid

