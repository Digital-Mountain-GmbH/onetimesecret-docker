FROM ruby:3.2-slim-bullseye
RUN mkdir /app/
RUN apt install git
RUN git clone https://github.com/onetimesecret/onetimesecret.git
WORKDIR /app/onetimesecret
RUN  bundle install --frozen
RUN  bin/ots init
RUN  sudo mkdir /var/log/onetime /var/run/onetime /var/lib/onetime
RUN  sudo chown ots /var/log/onetime /var/run/onetime /var/lib/onetime
RUN  mkdir /etc/onetime
RUN  cp -rp etc/* /etc/onetime/
RUN  chown -R ots /etc/onetime /var/lib/onetime
RUN  chmod -R o-rwx /etc/onetime /var/lib/onetime

ENTRYPOINT bundle exec thin -d -S /var/run/thin/thin.sock -l /var/log/thin/thin.log -P /var/run/thin/thin.pid -e prod -s 2 restart