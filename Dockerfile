FROM alpine:latest as builder

ENV qbt_qbittorrent_tag=release-4.5.4
ENV qbt_libtorrent_tag=v2.0.9
ENV qbt_patches_url=bradyslot/greedy-torrent-patch

RUN apk update && apk add curl bash

RUN echo qbt_qbittorrent_tag=$qbt_qbittorrent_tag
RUN echo qbt_libtorrent_tag=$qbt_libtorrent_tag
RUN echo qbt_patches_url=$qbt_patches_url
RUN curl -sL https://git.io/qbstatic | bash -s all \
  --qbittorrent-tag $qbt_qbittorrent_tag \
  --libtorrent-tag $qbt_libtorrent_tag

FROM alpine:latest as final

ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"
ENV PUID=1000
ENV PGID=1000

COPY --from=builder /qbt-build/completed/qbittorrent-nox /usr/bin/

EXPOSE 8080 6881 6881/udp
VOLUME /config
VOLUME /downloads

RUN addgroup -g $PGID abc
RUN adduser -u $PUID -G abc -h $HOME -s /bin/false -D abc

USER abc
CMD ["qbittorrent-nox", "--webui-port=8080"]
