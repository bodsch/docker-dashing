FROM alpine:3.3

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="0.1.0"

#EXPOSE 3030

# ---------------------------------------------------------------------------------------

RUN \
  apk update && \
  apk add \
    build-base \
    git \
    nodejs \
    ruby-dev \
    ruby-irb \
    ruby-io-console \
    ruby-rdoc \
    supervisor

RUN \
  gem install \
    bundle \
    dashing && \
  bundle install

#RUN \
#  mkdir /opt && \
#  cd /opt && \
#  git clone https://github.com/Icinga/dashing-icinga2.git

RUN \
  apk del --purge \
    git
    build-base \
    ruby-dev && \
    rm -rf /tmp/* /var/cache/apk/*

#ADD rootfs/opt/dashing-icinga2/config.ru /opt/dashing-icinga2/config.ru

#CMD [ "/usr/bin/supervisord" ]

CMD [ '/bin/sh' ]
# EOF
