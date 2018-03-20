#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
source ${SCRIPT_DIR}/common.sh

YML1=${YML_DIR}/docker-compose-redis.yml

docker-compose -f $YML1 $*
