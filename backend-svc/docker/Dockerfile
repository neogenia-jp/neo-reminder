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
ENV TERM=xterm

#####################################################
# install gdb, sshd, any more
RUN apt-get update \
    && apt-get install -y gdb openssh-server \
    moreutils
    
RUN apt-get install -y \
  libboost-dev \
  libsqlite3-dev \
  libvsqlitepp-dev

# add user
RUN useradd neo -m -s /bin/bash \
 && echo 'neo:neo' | chpasswd

#####################################################
# add scripts
ADD resources/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
WORKDIR /mnt

EXPOSE 22
