#!/usr/bin/env bash

PUID=${PUID:-1000}
PGID=${PGID:-1000}

grep -q ":${PGID}:$" /etc/group || addgroup -g "$PGID" abc
grep -q "^abc:" /etc/passwd || adduser -u "$PUID" -G abc -h "$HOME" -s /bin/false -D abc

chown -R abc:abc /config
chown -R abc:abc /downloads

su -c '/usr/bin/qbittorrent-nox --webui-port=8080' abc
