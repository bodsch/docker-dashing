
FROM alpine:edge

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1.1.0"

EXPOSE 3030

# ---------------------------------------------------------------------------------------

RUN \
  apk --quiet update && \
  apk --quiet upgrade

RUN \
  rm -Rf /var/run && \
  ln -s /run /var/run

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
  gem install --quiet bundle && \
  gem install --quiet dashing

RUN \
  mkdir /opt && \
  cd /opt && \
  git clone --quiet https://github.com/Shopify/dashing.git && \
  cd dashing && \
  dashing new icinga2 && \
  cd icinga2 && \
  echo -e "\ngem 'rest-client'\n" >> Gemfile && \
  bundle

RUN \
  apk del --purge \
    git \
    build-base \
    ruby-dev && \
  rm -rf /var/cache/apk/*

ADD rootfs/ /

WORKDIR /opt/dashing/icinga2

CMD [ "/opt/startup.sh" ]

# EOF
