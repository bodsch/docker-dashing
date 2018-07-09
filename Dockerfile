
FROM alpine:3.8

EXPOSE 3030

ARG BUILD_DATE
ARG BUILD_VERSION
ARG D3_VERSION
ARG JQ_VERSION
ARG JQUI_VERSION
ARG FONT_AWESOME

ENV \
  TERM=xterm \
  TZ='Europe/Berlin'

LABEL \
  version=${BUILD_VERSION} \
  maintainer="Bodo Schulz <bodo@boone-schulz.de>" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="Dashing Docker Image" \
  org.label-schema.description="Inofficial Dashing Docker Image" \
  org.label-schema.url="https://github.com/Smashing/smashing" \
  org.label-schema.vcs-url="https://github.com/bodsch/docker-dashing" \
  org.label-schema.vendor="Bodo Schulz" \
  org.label-schema.version=${ICINGA_VERSION} \
  org.label-schema.schema-version="1.0" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="GNU General Public License v3.0"

# ---------------------------------------------------------------------------------------

COPY build /

RUN \
  apk update  --quiet --no-cache && \
  apk upgrade --quiet --no-cache && \
  apk add --quiet --virtual .build-deps \
    build-base git ruby-dev libffi-dev && \
  apk add --quiet --no-cache  \
    curl \
    nodejs \
    ruby \
    ruby-io-console \
    tzdata && \
  echo 'gem: --no-document' >> /etc/gemrc && \
  gem install --no-rdoc --no-ri --quiet bundle && \
  cd /opt && \
  bundle update --quiet && \
  ln -s $(ls -1 /usr/lib/ruby/gems) /usr/lib/ruby/gems/current && \
  ln -s $(ls -d1 /usr/lib/ruby/gems/current/gems/smashing-*) /usr/lib/ruby/gems/current/gems/smashing && \
  echo "update some packages ..." && \
  echo " - jquery ${JQ_VERSION}" && \
  curl \
    --silent \
    --output /usr/lib/ruby/gems/current/gems/smashing/javascripts/jquery.js \
    https://code.jquery.com/jquery-${JQ_VERSION}.min.js && \
  echo " - jquery-ui ${JQUI_VERSION}" && \
  curl \
    --silent \
    --output /tmp/jquery-ui-${JQUI_VERSION}.zip \
     http://jqueryui.com/resources/download/jquery-ui-${JQUI_VERSION}.zip && \
  echo " - fontawesome ${FONT_AWESOME}" && \
  curl \
    --silent \
    --output /tmp/font-awesome-${FONT_AWESOME}.zip \
    https://fontawesome.com/v${FONT_AWESOME}/assets/font-awesome-${FONT_AWESOME}.zip && \
  cd /tmp && \
  echo " - jQuery-Knob" && \
  git clone https://github.com/aterrien/jQuery-Knob.git 2> /dev/null && \
  mv jQuery-Knob/js/jquery.knob.js /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/javascripts/jquery.knob_new.js && \
  cd /tmp && \
  echo " - rickshaw" && \
  git clone https://github.com/shutterstock/rickshaw.git 2> /dev/null && \
  mv /tmp/rickshaw/rickshaw.min.js /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/javascripts/ && \
  cd /tmp && \
  echo " - d3 ${D3_VERSION}" && \
  curl \
    --silent \
    --location \
    --output /tmp/d3.zip \
    https://github.com/d3/d3/releases/download/v${D3_VERSION}/d3.zip && \
  unzip d3.zip > /dev/null && \
  mv d3.*js /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/javascripts/ && \
  cd /tmp && \
  unzip jquery-ui-${JQUI_VERSION}.zip > /dev/null && \
  cp /tmp/jquery-ui-${JQUI_VERSION}/*.min.js     /usr/lib/ruby/gems/current/gems/smashing/javascripts/ && \
  cp /tmp/jquery-ui-${JQUI_VERSION}/*.min.css    /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/stylesheets/ && \
  cp /tmp/jquery-ui-${JQUI_VERSION}/images/*     /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/images/ && \
  rm -rf /tmp/jquery* && \
  unzip font-awesome-${FONT_AWESOME}.zip > /dev/null && \
  cp font-awesome-${FONT_AWESOME}/fonts/*   /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/fonts/ && \
  cp font-awesome-${FONT_AWESOME}/css/*.css /usr/lib/ruby/gems/current/gems/smashing/templates/project/assets/stylesheets/ && \
  apk del --quiet --purge .build-deps && \
 rm -rf \
    /tmp/* \
    /build \
    /var/cache/apk/* \
    /usr/lib/ruby/gems/current/cache/* \
    /root/.gem \
    /root/.bundle

CMD [ "/bin/sh" ]
