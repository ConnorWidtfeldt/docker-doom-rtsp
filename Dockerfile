FROM alpine:3

RUN apk add --no-cache bash ffmpeg supervisor wget xvfb xdotool xvfb-run \
    && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing chocolate-doom

ARG RTSP_SIMPLE_SERVER_VERSION=0.21.2
RUN wget https://github.com/aler9/rtsp-simple-server/releases/download/v${RTSP_SIMPLE_SERVER_VERSION}/rtsp-simple-server_v${RTSP_SIMPLE_SERVER_VERSION}_linux_amd64.tar.gz -O rtsp-simple-server.tar.gz \
    && tar -xzvf rtsp-simple-server.tar.gz \
    && mv rtsp-simple-server /usr/local/bin/rtsp-simple-server

COPY --from=mattipaksula/doom1wad /doom1.wad /doom1.wad

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY doom.cfg /doom.cfg
COPY rtsp-simple-server.yml /rtsp-simple-server.yml
COPY supervisord.conf /supervisord.conf

ENV XDG_RUNTIME_DIR=/tmp

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/supervisord.conf"]
