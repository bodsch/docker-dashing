FROM alpine:3.3

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1.0.0"

EXPOSE 3030

# ---------------------------------------------------------------------------------------

RUN \
  apk --quiet update && \
  apk --quiet upgrade

RUN \
  apk --quiet add \
    build-base \
    git \
    nodejs \
    ruby-dev \
    ruby-irb \
    ruby-io-console \
    ruby-rdoc \
    supervisor

RUN \
  gem install --quiet bundle

RUN \
  gem install --quiet dashing

RUN \
  mkdir /opt && \
  cd /opt && \
  git clone --quiet https://github.com/Icinga/dashing-icinga2.git && \
  cd /opt/dashing-icinga2 && \
  bundle install

RUN \
  apk del --purge \
    git \
    build-base \
    ruby-dev && \
  rm -rf /var/cache/apk/*

ADD rootfs/ /

CMD [ "/opt/startup.sh" ]

# EOF
