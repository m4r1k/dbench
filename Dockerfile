FROM alpine:3.16

MAINTAINER Federico Iezzi <fiezzi@google.com>

RUN apk add --no-cache \
    bash \
    sudo \
    lsblk \
    util-linux \
    procps \
    fio==3.30-r0

VOLUME /tmp
WORKDIR /tmp
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["fio"]
