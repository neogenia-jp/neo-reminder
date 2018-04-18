#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

function exec_backend() {
  echo "#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=# ROUTE=$1 #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#"
  TEST=$1 bash $SCRIPT_DIR/run-docker-compose-backend.sh up
}

if [ -z $1 ]; then
  echo "$0 <route|'all'>"
  exit 1
else
  bash $SCRIPT_DIR/run-docker-compose-backend.sh build
  if [ $1 == 'all' ]; then
    exec_backend 'yamamoto'
    exec_backend 'yoneoka'
    exec_backend 'kamada'
    exec_backend 'moriguchi'
    exec_backend 'maeda'
  else
    exec_backend "$1"
  fi
fi

