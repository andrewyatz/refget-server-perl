FROM alpine:3.4
MAINTAINER ayates

COPY cpanfile /
ENV EV_EXTRA_DEFS -DEV_NO_ATFORK

RUN apk update && \
  apk add perl perl-io-socket-ssl perl-dbd-pg perl-dev g++ make wget curl && \
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

RUN chown -R mydocker:mydocker /home/mydocker $APP_DIR/log $APP_DIR/tmp

USER mydocker
EXPOSE 8080
WORKDIR $APP_DIR
ENV APP_PID_FILE=${APP_DIR}/tmp/hypnotoad.pid
CMD ["hypnotoad", "-f", "/app/bin/app.pl"]
