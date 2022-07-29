FROM dmonakhov/alpine-fio

MAINTAINER Federico Iezzi <fiezzi@google.com>

VOLUME /tmp
WORKDIR /tmp
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["fio"]
