# == RTSP SIMPLE SERVER == #
FROM --platform=${BUILDPLATFORM} alpine:3 AS rtsp-simple-server

RUN apk add --no-cache wget

ARG TARGETPLATFORM
ARG VERSION=0.21.4
RUN case ${TARGETPLATFORM} in "linux/amd64") ARCH=amd64 ;; "linux/arm/v6") ARCH=armv6 ;; "linux/arm/v7") ARCH=armv7 ;; "linux/arm64") ARCH=arm64v8 ;; esac \
    && wget -q https://github.com/aler9/rtsp-simple-server/releases/download/v${VERSION}/rtsp-simple-server_v${VERSION}_linux_${ARCH}.tar.gz -O rtsp-simple-server.tar.gz \
    && tar -xzvf rtsp-simple-server.tar.gz \
    && mv rtsp-simple-server /usr/local/bin/rtsp-simple-server

# == RUNTIME == #
FROM --platform=${TARGETPLATFORM} alpine:3 AS runtime

RUN apk add --no-cache ffmpeg supervisor xvfb \
    && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing chocolate-doom

COPY --from=rtsp-simple-server /usr/local/bin/rtsp-simple-server /usr/local/bin/rtsp-simple-server
COPY --from=mattipaksula/doom1wad /doom1.wad /doom1.wad

COPY doom.cfg /doom.cfg
COPY rtsp-simple-server.yml /rtsp-simple-server.yml
COPY supervisord.conf /supervisord.conf

ENV XDG_RUNTIME_DIR=/tmp

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/supervisord.conf"]
