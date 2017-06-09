
FROM alpine:3.6

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1.4.1"

EXPOSE 3030

ENV \
  ALPINE_MIRROR="mirror1.hs-esslingen.de/pub/Mirrors" \
  ALPINE_VERSION="v3.6" \
  DASHBOARD="icinga2" \
  JQ_VERSION=2.2.2 \
  JQUI_VERSION=1.11.4 \
  DASHING_VERSION=1.3.7 \
  FONT_AWESOME=4.7.0

# ---------------------------------------------------------------------------------------

COPY build /

RUN \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/main"       > /etc/apk/repositories && \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
  apk --no-cache update && \
  apk --no-cache upgrade && \

  apk --no-cache add \
    build-base \
    curl \
    git \
    nodejs-current \
    supervisor \
    ruby-dev \
    ruby-irb \
    ruby-io-console \
    libffi-dev && \

  gem install --no-rdoc --no-ri bundle && \

  cd /opt && \
  bundle update && \

  ln -s $(ls -1 /usr/lib/ruby/gems) /usr/lib/ruby/gems/current && \
  ln -s $(ls -d1 /usr/lib/ruby/gems/current/gems/smashing-*) /usr/lib/ruby/gems/current/gems/smashing && \

  cd /opt && \
  smashing new ${DASHBOARD} && \
  cd ${DASHBOARD} && \
  bundle install && \

  rm -f /opt/${DASHBOARD}/jobs/twitter* && \
  rm -f /opt/${DASHBOARD}/dashboards/* && \

  cd /opt && \
  git clone https://github.com/bodsch/ruby-icinga2.git && \
  cd ruby-icinga2 && \
  gem install --quiet --no-rdoc --no-ri ./icinga2-1.4.10.gem && \

  cd /opt && \
  curl \
    --silent \
    --output /usr/lib/ruby/gems/current/gems/smashing/javascripts/jquery.js \
    https://code.jquery.com/jquery-${JQ_VERSION}.min.js && \

  cd /opt && \
  curl \
    --silent \
    --output /tmp/jquery-ui-${JQUI_VERSION}.zip \
    http://jqueryui.com/resources/download/jquery-ui-${JQUI_VERSION}.zip && \

  cd /opt && \
  curl \
    --silent \
    --output /tmp/font-awesome-${FONT_AWESOME}.zip \
    http://fontawesome.io/assets/font-awesome-${FONT_AWESOME}.zip && \

  cd /tmp && \
  unzip jquery-ui-${JQUI_VERSION}.zip > /dev/null && \
  cp /tmp/jquery-ui-${JQUI_VERSION}/*.min.js     /usr/lib/ruby/gems/current/gems/smashing/javascripts/ && \
  cp /tmp/jquery-ui-${JQUI_VERSION}/*.min.css    /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/stylesheets/ && \
  cp /tmp/jquery-ui-${JQUI_VERSION}/images/*     /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/images/ && \
  rm -rf /tmp/jquery* && \

  cd /tmp && \
  unzip font-awesome-${FONT_AWESOME}.zip > /dev/null && \
  cp font-awesome-${FONT_AWESOME}/fonts/*   /opt/${DASHBOARD}/assets/fonts/ && \
  cp font-awesome-${FONT_AWESOME}/css/*.css /opt/${DASHBOARD}/assets/stylesheets/ && \

  apk del --purge \
    git \
    build-base \
    ruby-dev \
    libffi-dev && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/* \
    /opt/ruby-icinga2

COPY rootfs/ /

WORKDIR /opt/${DASHBOARD}

CMD [ "/init/run.sh" ]

# ---------------------------------------------------------------------------------------
