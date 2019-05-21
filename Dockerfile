FROM alpine:3.4
LABEL maintainer="ayates"

COPY cpanfile /
ENV EV_EXTRA_DEFS -DEV_NO_ATFORK

RUN apk update && \
  apk add perl perl-io-socket-ssl perl-dbd-pg perl-dev g++ make wget curl tar && \
  curl -L https://cpanmin.us | perl - App::cpanminus && \
  cpanm --installdeps --notest . -M https://cpan.metacpan.org && \
  apk del perl-dev g++ make wget curl && \
  rm -rf /root/.cpanm/* /usr/local/share/man/*

ENV APP_DIR=/app
ADD ./lib ${APP_DIR}/lib
ADD ./bin ${APP_DIR}/bin
ADD ./templates ${APP_DIR}/templates

RUN chmod +x $APP_DIR/bin/*.pl; \
    mkdir -p $APP_DIR/log $APP_DIR/tmp; \
    addgroup -S mydocker; \
    adduser -S -g mydocker mydocker ; \
    rm -f $APP_DIR/log/* $APP_DIR/tmp/*;

RUN chgrp -R 0 /home/mydocker $APP_DIR/log $APP_DIR/tmp && \
    chmod -R g=u /home/mydocker $APP_DIR/log $APP_DIR/tmp

USER mydocker

RUN tar zxf compliance-data.tar.gz
COPY .heroku/refget-app.heroku.json.template $APP_DIR/refget-app.docker.json

EXPOSE 8080
WORKDIR $APP_DIR

ENV APP_PID_FILE=${APP_DIR}/tmp/hypnotoad.pid
ENV PERL5LIB=${APP_DIR}/lib:${PERL5LIB}
ENV MOJO_CONFIG=${APP_DIR}/refget-app.docker.json 
ENV DATABASE_URL=sqlite:///${APP_DIR}/compliance-data/compliance.db 

# ENV APP_ACCESS_LOG_FILE=${APP_DIR}/log/access.log

CMD ["hypnotoad", "-f", "/app/bin/app.pl"]
