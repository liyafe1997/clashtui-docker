#!/bin/sh
set -e

# OpenRC without being PID 1
mkdir -p /run/openrc && touch /run/openrc/softlevel

# Seed /data on first run
[ -e /data/clashtui/config.yaml ] || cp -a /opt/clashtui/skel/clashtui /data/
[ -e /data/mihomo/config.yaml ] || cp -a /opt/clashtui/skel/mihomo /data/
chmod g+s /data/mihomo && chmod -R g+w /data/mihomo

rc-service clashtui_mihomo start

[ $# -eq 0 ] || exec "$@"

trap 'rc-service clashtui_mihomo stop; exit 0' TERM INT
while :; do sleep 86400 & wait $!; done
