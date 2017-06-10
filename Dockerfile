
FROM alpine:3.6

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

ENV \
  ALPINE_MIRROR="mirror1.hs-esslingen.de/pub/Mirrors" \
  ALPINE_VERSION="v3.6" \
  TERM=xterm \
  BUILD_DATE="2017-06-10" \
  JQ_VERSION=2.2.2 \
  JQUI_VERSION=1.11.4 \
  FONT_AWESOME=4.7.0

EXPOSE 3030

LABEL \
  version="1706-02" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="Smashing Docker Image" \
  org.label-schema.description="Inofficial Smashing Docker Image" \
  org.label-schema.url="https://github.com/Smashing/smashing" \
  org.label-schema.vcs-url="https://github.com/bodsch/docker-smashing" \
  org.label-schema.vendor="Bodo Schulz" \
  org.label-schema.version=${ICINGA_VERSION} \
  org.label-schema.schema-version="1.0" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="GNU General Public License v3.0"

# ---------------------------------------------------------------------------------------

COPY build /

RUN \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/main"       > /etc/apk/repositories && \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
  apk update  --quiet --no-cache && \
  apk upgrade --quiet --no-cache && \

  apk add --quiet --no-cache  \
    build-base \
    curl \
    git \
    nodejs-current \
    ruby \
    ruby-dev \
    ruby-io-console \
    libffi-dev && \

  gem install --no-rdoc --no-ri --quiet bundle && \

  cd /opt && \
  bundle update --quiet && \

  ln -s $(ls -1 /usr/lib/ruby/gems) /usr/lib/ruby/gems/current && \
  ln -s $(ls -d1 /usr/lib/ruby/gems/current/gems/smashing-*) /usr/lib/ruby/gems/current/gems/smashing && \

  # update jquery
  #
  curl \
    --silent \
    --output /usr/lib/ruby/gems/current/gems/smashing/javascripts/jquery.js \
    https://code.jquery.com/jquery-${JQ_VERSION}.min.js && \

  # update jquery-ui
  #
  curl \
    --silent \
    --output /tmp/jquery-ui-${JQUI_VERSION}.zip \
    http://jqueryui.com/resources/download/jquery-ui-${JQUI_VERSION}.zip && \

  # update font-awesome
  #
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

  unzip font-awesome-${FONT_AWESOME}.zip > /dev/null && \
  cp font-awesome-${FONT_AWESOME}/fonts/*   /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/fonts/ && \
  cp font-awesome-${FONT_AWESOME}/css/*.css /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/stylesheets/ && \

  apk del --quiet --purge \
    build-base \
    git \
    ruby-dev \
    libffi-dev && \
  rm -rf \
    /tmp/* \
    /build \
    /var/cache/apk/* \
    /usr/lib/ruby/gems/current/cache/*

CMD [ "/bin/sh" ]

# ---------------------------------------------------------------------------------------
