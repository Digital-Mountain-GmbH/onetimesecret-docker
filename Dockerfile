FROM ruby:2.6-slim AS builder
RUN mkdir /app/
WORKDIR /app/
RUN apt update && apt install git -y
RUN git clone https://github.com/onetimesecret/onetimesecret.git
RUN ls -ahl /app/onetimesecret
WORKDIR /app/onetimesecret
RUN git pull

RUN gem install bundler:2.3.17
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
