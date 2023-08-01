# Greedy Torrent

[![CI](https://github.com/bradyslot/greedy-torrent/actions/workflows/ci.yml/badge.svg)](https://github.com/bradyslot/greedy-torrent/actions)
[![GHCR](https://img.shields.io/badge/latest-blue?style=flat&logo=docker&logoColor=ffffff&label=greedy-torrent&labelColor=555555&color=0366d6)](https://ghcr.io/bradyslot/greedy-torrent)

Download your favourite Linux ISO's in peace knowing that the powers that be
will not mistake you for one of those filthy pirates.  

## Only Receive Never Send

- Breaking the law is bad mmmk...
- You shouldn't be sharing files with strangers on the internet, kids.
- Don't disappoint your Big Brother now :eyes:

This is a dockerized static qbittorrent-nox that is built against a patched
version of libtorrent with the function body of [bt_peer_connection::write_piece](https://github.com/arvidn/libtorrent/blob/RC_2_0/src/bt_peer_connection.cpp#L2632)
commented into a no_op.  

This function is responsible for sending blocks of a file to a remote peer, as 
well as some bookkeeping around stats and alerts.  

This way 0 bytes of file data are ever sent back to peer connections, handshakes
and other protocol communications are unaffected and the client chugs along
happily in this state.  

I wanna give mad props to [qbittorrent-nox-static](https://github.com/userdocs/qbittorrent-nox-static)
for providing a god tier build script that builds a statically compiled version
of qbittorrent-nox, works with most architectures and includes and out of the
box way to apply patches.  

## Uses

*libtorrent:* v2.0.9
*qBittorrent:* release-4.5.4

## How to use

I'm going to assume you can BYO your own qBittorrent.conf as well as all the
other config and data files associated with running qBittorrent.  

The /config volume mount is the users home directory that runs the service.  
It's also the XDG_CONFIG_HOME and XDG_DATA_HOME.  
The /downloads volume mount is obvious.  

The PUID of the user running the service is 1000.  
The PGID of the group the user is in is also 1000.  
This matches the primary single user account of most linux desktops.  
If you use a different uid and gid for the user account you run your docker
containers with, and you want that to match the permissions of the mounted
volumes, then you'll probably want to build your own.  

Or, eventually I'll figure out how to do user mappings and permissions within
docker compose like the way [linuxserver.io](https://docs.linuxserver.io/images/docker-qbittorrent)
does it.  

```yaml
---
version: "3"
services:
  greedy-torrent:
    build: .
    image: ghcr.io/bradyslot/greedy-torrent:latest
    hostname: greedy-torrent
    container_name: greedy-torrent
    volumes:
      - /example:/config
      - /example:/downloads
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped
```
