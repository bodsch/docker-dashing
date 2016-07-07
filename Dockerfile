FROM bodsch/docker-alpine-base:latest

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1.3.1"

EXPOSE 3030

ENV DASHBOARD=icinga2
ENV JQ_VERSION=2.2.2
ENV JQUI_VERSION=1.11.4
ENV DASHING_VERSION=1.3.4

# ---------------------------------------------------------------------------------------

RUN \
  apk --quiet --no-cache update && \
  apk --quiet --no-cache add \
    build-base \
    git \
    nodejs \
    ruby-dev \
    ruby-irb \
    ruby-io-console \
    ruby-rdoc \
    libffi-dev && \
  gem install --quiet bundle && \
  gem install --quiet dashing -v ${DASHING_VERSION} && \
  cd /opt && \
  git clone --quiet https://github.com/Dashing-io/dashing.git && \
  cd dashing && \
  dashing new ${DASHBOARD} && \
  cd ${DASHBOARD} && \
  echo -e "\n" >> Gemfile && \
  echo "gem 'rest-client'"     >> Gemfile && \
  bundle update && \
  ln -s $(ls -1 /usr/lib/ruby/gems) /usr/lib/ruby/gems/current && \
  ln -s /usr/lib/ruby/gems/current/gems/dashing-${DASHING_VERSION} /usr/lib/ruby/gems/current/gems/dashing && \
  curl --silent https://code.jquery.com/jquery-${JQ_VERSION}.min.js > /usr/lib/ruby/gems/current/gems/dashing/javascripts/jquery.js && \
  curl --silent http://jqueryui.com/resources/download/jquery-ui-${JQUI_VERSION}.zip > /tmp/jquery-ui-${JQUI_VERSION}.zip && \
  cd /tmp && \
  unzip jquery-ui-${JQUI_VERSION}.zip && \
  cp /tmp/jquery-ui-${JQUI_VERSION}/*.min.js     /usr/lib/ruby/gems/current/gems/dashing/javascripts/ && \
  cp /tmp/jquery-ui-${JQUI_VERSION}/*.min.css    /usr/lib/ruby/gems/current/gems/dashing/templates/project/assets/stylesheets/ && \
  cp /tmp/jquery-ui-${JQUI_VERSION}/images/*     /usr/lib/ruby/gems/current/gems/dashing/templates/project/assets/images/ && \
  rm -rf /tmp/jquery* && \
  rm -rf /opt/dashing/${DASHBOARD}/jobs/buzzwords.rb && \
  rm -rf /opt/dashing/${DASHBOARD}/jobs/convergence.rb && \
  rm -rf /opt/dashing/${DASHBOARD}/jobs/sample.rb && \
  rm -rf /opt/dashing/${DASHBOARD}/jobs/twitter.rb && \
  rm -rf /opt/dashing/${DASHBOARD}/jobs/timeline.rb && \
  apk del --purge \
    git \
    build-base \
    ruby-dev \
    libffi-dev && \
  rm -rf /var/cache/apk/*

ADD rootfs/ /

WORKDIR /opt/dashing/${DASHBOARD}

CMD [ "/opt/startup.sh" ]

# EOF
