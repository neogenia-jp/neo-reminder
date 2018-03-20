#!/bin/bash

cd $RAILS_ROOT_DIR

# change vendor permission
chown www-data:www-data vendor

# ディレクトリの権限チェックと自動作成
function check_dir() {
  if [ -d $1 ]; then
    if su www-data -c "[ ! -w $1 ]"; then
      echo "##### ERROR ##### directory $(pwd)/$1 is not writable"
      exit 2
    fi
  else
    su www-data -c "mkdir $1"
    if [ $? -ne 0 ]; then
      echo "##### ERROR ##### failed mkdir $(pwd)/$1"
      exit 3
    fi
  fi
}

# Check "tmp" directory's permission.
check_dir 'tmp'

# Check "log" directory's permission.
check_dir 'log'

if [ "$1" = "manual" ] ; then
  echo '***** MANUAL MODE *****'
  echo "Prease exec below command on host:"
  echo '  docker exec -ti backend_svc bash'
  exec tail -f /dev/null
  exit
fi

echo "start bundle install"
su www-data -c 'bundle install -j$(nproc)'
if [ $? -ne 0 ]; then
  echo "##### ERROR ##### failed bundle install"
  exit 4
fi

if [ "$RAILS_ENV" = "production" ]; then
  echo "start assets:precompile"
  su www-data -c 'bin/rails assets:precompile'
  if [ $? -ne 0 ]; then
    echo "##### ERROR ##### failed assets:precompile"
    exit 6
  fi
fi

# PIDファイルを削除
rm tmp/puma.pid 2>/dev/null

bin/delayed_job start

bin/rails s -b 0.0.0.0 -p 8082


