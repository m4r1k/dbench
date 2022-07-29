FROM alpine:3.16

LABEL maintainer="Federico Iezzi <fiezzi@google.com>"

RUN apk add --no-cache \
    bash \
    sudo \
    lsblk \
    util-linux \
    procps \
    fio==3.30-r0

VOLUME /tmp

WORKDIR /tmp

COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["fio"]
