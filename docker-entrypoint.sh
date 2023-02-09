#!/usr/bin/env sh
set -euo pipefail

echo "starting..."

_term() {
    echo "TERM"
    exit 0
}
_forever() {
    while true; do
        set +e
        $@
        set -e
    done
}
_wait_for_x() {
    while true; do
        xdpyinfo >/dev/null 2>&1 && break
        sleep 0.1
    done
}
trap '_term' TERM

(
    rm >/dev/null 2>&1 /tmp/.X0-lock || true

    exec Xvfb "$DISPLAY" -screen 0 "640x480x24"
) >/tmp/xvfb.log 2>&1 &
xvfb_pid=$!

(
    _wait_for_x
    x11vnc \
        -display "$DISPLAY" \
        -shared \
        -clear_all \
        -loop0 \
        -nolookup \
        -nocursor \
        -nopw
) >/tmp/x11vnc.log 2>&1 &
x11vnc_pid=$!

(
    while true; do
        (
            exec chocolate-doom -nogui -iwad /doom1.wad -window -nograbmouse -nosound -nomouse -config /app/chocolate-doom.cfg
        ) >/tmp/chocolate-doom.log 2>&1 &
        chocolate_doom_pid=$!

        while true; do
            kill >/dev/null 2>&1 -0 $chocolate_doom_pid || break
            sleep 0.5
        done

        (
            set +e
            kill -9 $chocolate_doom_pid
            set -e
        ) >/dev/null 2>&1 &
    done
) &

wait $xvfb_pid
