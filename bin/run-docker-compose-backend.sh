#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
source ${SCRIPT_DIR}/common.sh

YML_FILE=${YML_DIR}/docker-compose-backend.yml

docker-compose -f ${YML_FILE} $*
