# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
RUN set -xe \
    && apk add --no-cache --purge -uU \
        openssl \
        rsync \
    && mkdir -p /defaults \
    && mv /etc/rsyncd.conf /defaults/rsyncd.conf.default \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME /etc/rsyncd/ /etc/rsyncd.d/ /storage/
#
EXPOSE 873
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    rsync -t rsync://${HEALTHCHECK_URL:-${RSYNCD_USER:-root}@localhost} --port ${RSYNCD_PORT:-873} || exit 1
#
ENTRYPOINT ["/init"]
