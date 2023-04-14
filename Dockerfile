FROM ruby:2.6-slim AS builder
WORKDIR /app/

ARG PACKAGES="build-essential autoconf m4 sudo git"
ARG ADDITIONAL_PACKAGES="curl netcat vim-tiny less redis-tools iproute2 iputils-ping iftop pktstat pcp iptraf"
RUN set -eux && \
    apt-get update && \
    apt-get install -y $PACKAGES && \
    apt-get install -y $ADDITIONAL_PACKAGES

RUN git clone https://github.com/Digital-Mountain-GmbH/onetimesecret-x84_64/ .

RUN gem install bundler:2.3.17
RUN bundle lock --add-platform x86_64-linux
RUN bundle config set --local frozen 'true'
RUN bundle config set --local deployment 'true'
RUN bundle config set --local without 'dev'
RUN bundle install

RUN  bin/ots init
RUN  sudo mkdir /var/log/onetime /var/run/onetime /var/lib/onetime
RUN  sudo chown ots /var/log/onetime /var/run/onetime /var/lib/onetime
RUN  mkdir /etc/onetime
RUN  cp -rp etc/* /etc/onetime/
RUN  chown -R ots /etc/onetime /var/lib/onetime
RUN  chmod -R o-rwx /etc/onetime /var/lib/onetime

ENTRYPOINT bundle exec thin -d -S /var/run/thin/thin.sock -l /var/log/thin/thin.log -P /var/run/thin/thin.pid -e prod -s 2 restart
