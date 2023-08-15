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

**libtorrent:** v2.0.9  
**qBittorrent:** release-4.5.4  

## How to use

BYO qBittorrent.conf & data
`~/.config/qBittorrent/` and `~/.local/share/qBittorrent/` live in the `/config`
mount.  
The `/downloads` mount is obvious.  
Set the PUID and PGID to a user:group with read+write permissions on the volumes.  

**example docker-compose.yml:**  
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
    environment:
      - PGID=1000
      - PUID=1000
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped
```
