FROM neogenia/ruby2.5-many-others

LABEL maintainer "Wataru Maeda <w.maeda@neogenia.co.jp>"

#####################################################
# timezone, lang settings
RUN ln -sf /usr/share/zoneinfo/Japan /etc/localtime

RUN echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=ja_JP.UTF-8

ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:en
ENV LC_ALL ja_JP.UTF-8

#####################################################
# install gdb, sshd
RUN apt-get update \
    && apt-get install -y gdb openssh-server

# add user
RUN useradd neo \
 && echo 'neo:neo' | chpasswd

#####################################################
# set environment valiables
# RAILSアプリルートディレクトリのマウント先
ARG rails_app_mount_to=/var/rails
# アプリケーション制御スクリプトのコピー先
ARG scripts_copy_to=/var/scripts

ENV TERM=xterm \
    RAILS_ROOT_DIR=$rails_app_mount_to \
    SCRIPTS_ROOT_DIR=$scripts_copy_to

#####################################################
# add scripts
ADD resources/scripts $scripts_copy_to
RUN chmod +x $scripts_copy_to

WORKDIR $rails_app_mount_to

EXPOSE 8082 10022

