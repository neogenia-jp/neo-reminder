#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

cd $SCRIPT_DIR

chronic make db_tool \
  && ./db_tool_main db_tool/migrations main


