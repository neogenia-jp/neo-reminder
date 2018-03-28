#!/bin/bash

case $ROUTE in
  "moriguchi" ) exec CppBackendSvc/entry_point.sh ;;
  "maeda"     ) exec CppBackendSvc/entry_point.sh ;;
  "yamamoto"  ) exec ruby ruby_backend_svc/src/entrypoint.rb ;;
  "yoneoka"   ) exec ruby ruby_backend_svc/src/entrypoint.rb ;;
  "kamada"    ) exec ruby ruby_backend_svc/src/entrypoint.rb ;;
  * ) echo "### ERROR ### UNKNOWN ROUTE '$ROUTE' !!"; exit 1 ;;
esac

