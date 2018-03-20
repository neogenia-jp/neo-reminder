SCRIPT_DIR=${SCRIPT_DIR:-$(cd $(dirname $0) && pwd)}
YML_DIR=${SCRIPT_DIR}/yml

#環境依存設定ファイル読み込み
# これらのファイルはgit管理されていないため、環境に応じて用意してください。
# env_configディレクトリの下にある各種xxx.sampleをコピーし適宜コメントアウトして定義してください。

source_if_exists () {
  if [ -f "$1" ]; then
    source $1
  fi
}

# 環境変数
source_if_exists $SCRIPT_DIR/env_config/env_app.sh

export DOCKER_HOST_HOSTNAME=`hostname`

export DOCKER_COMMAND=${EXT_DOCKER_COMMAND:-docker}

export COMPOSE_PROJECT_NAME=rmd

# front-app
export RAILS_WEBAPP_DOCKERFILE_DIR=${SCRIPT_DIR}/../front-app/docker
export RAILS_APP_ROOT_DIR=${SCRIPT_DIR}/../front-app/app/webapp
export RAILS_APP_MOUNT_TO=/var/rails
export SCRIPTS_MOUNT_TO=/var/scripts
export EXTERNAL_FILES_ROOT_DIR=${EXTERNAL_FILES_ROOT_DIR:-${SCRIPT_DIR}/../front-app/extfiles}
export EXTERNAL_FILES_MOUNT_TO=/var/extfiles
export RAILS_APP_ENV=${RAILS_APP_ENV:-development}

# backend-svc
export BACKEND_DOCKERFILE_DIR=${SCRIPT_DIR}/../backend-svc/docker
export BACKEND_SRC_ROOT_DIR=${SCRIPT_DIR}/../backend-svc/src

# redis-server
export REDIS_DOCKERFILE_DIR=${SCRIPT_DIR}/../redis-server/docker

# mocksmtp
export MOCKSMTP_DOCKERFILE_DIR=${SCRIPT_DIR}/../mocksmtp/docker
