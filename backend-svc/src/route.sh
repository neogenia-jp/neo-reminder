#!/bin/bash

cd /mnt

case $ROUTE in
  "moriguchi" ) exec bash CppBackendSvc/entrypoint.sh ;;
  "maeda"     ) exec bash CppBackendSvc/entrypoint.sh ;;
  "yamamoto"  ) exec ruby ruby_backend_svc/src/entrypoint.rb ;;
  "yoneoka"   ) exec ruby ruby_backend_svc/src/entrypoint.rb ;;
  "kamada"    ) exec ruby ruby_backend_svc/src/entrypoint.rb ;;
  * ) echo "### ERROR ### UNKNOWN ROUTE '$ROUTE' !!"; exit 1 ;;
esac

