#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

chronic rsync -av /home/neo/projects/CppBackendSvc/bin/x64/Release "$SCRIPT_DIR" 1>&2 \
  && "$SCRIPT_DIR/Release/CppBackendSvc.out"
