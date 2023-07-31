FROM archlinux:base-devel

ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"
ENV PUID=1000
ENV PGID=1000

RUN pacman -Syu --noconfirm \
  git \
  cmake \
  ninja \
  boost \
  qt6-base \
  qt6-tools \
  && pacman -Scc --noconfirm

RUN git clone --recurse-submodules https://github.com/arvidn/libtorrent.git
COPY no_pieces_for_you.patch /libtorrent/no_pieces_for_you.patch
WORKDIR /libtorrent
RUN git apply no_pieces_for_you.patch
RUN mkdir build
WORKDIR /libtorrent/build
RUN cmake \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_CXX_STANDARD=20 \
  -D CMAKE_INSTALL_PREFIX=/usr \
  -G Ninja \
  ..
RUN ninja -j$(nproc)
RUN ninja install
WORKDIR /
RUN rm -rf /libtorrent

RUN git clone https://github.com/qbittorrent/qBittorrent.git
RUN mkdir /qBittorrent/build
WORKDIR /qBittorrent/build
RUN cmake \
  -D CMAKE_MODULE_PATH=/usr/lib/cmake/Qt5LinguistTools \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_CXX_STANDARD=20 \
  -D GUI=OFF \
  -G Ninja \
  ..
RUN ninja -j$(nproc)
RUN ninja install
WORKDIR /
RUN rm -rf /qBittorrent

EXPOSE 8080 6881 6881/udp
VOLUME /config
VOLUME /downloads

RUN groupadd -g $PGID abc && \
  useradd -u $PUID -g $PGID -d $HOME -s /bin/false abc

USER abc
CMD ["/bin/bash", "-c", "qbittorrent-nox --webui-port=8080"]
