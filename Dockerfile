FROM debian:latest

ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

ARG PUID
ARG PGID

RUN apt-get update && apt-get install -y \
  git \
  build-essential \
  cmake \
  libssl-dev \
  libboost-dev \
  zlib1g-dev \
  qt6-base-dev \
  qt6-tools-dev \
  && rm -rf /var/lib/apt/lists/*

RUN git clone --recurse-submodules https://github.com/arvidn/libtorrent.git
COPY no_pieces_for_you.patch /libtorrent/no_pieces_for_you.patch
WORKDIR /libtorrent
RUN git apply no_pieces_for_you.patch
RUN mkdir build
WORKDIR /libtorrent/build
RUN cmake \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_CXX_STANDARD=17 \
  -D CMAKE_CXX_STANDARD_REQUIRED=ON \
  -D CMAKE_CXX_EXTENSIONS=OFF \
  -D CMAKE_INSTALL_PREFIX=/usr \
  ..
RUN make -j$(nproc)
RUN make install
WORKDIR /
RUN rm -rf /libtorrent

RUN git clone https://github.com/qbittorrent/qBittorrent.git
WORKDIR /qBittorrent
RUN cmake -B build \
  -D CMAKE_MODULE_PATH=/usr/lib/x86_64-linux-gnu/cmake/Qt6LinguistTools \
  -D CMAKE_BUILD_TYPE=Release \
  -D GUI=OFF
RUN cmake --build build
RUN cmake --install build
WORKDIR /
RUN rm -rf /qBittorrent

EXPOSE 8080 6881 6881/udp
VOLUME /config
VOLUME /downloads

RUN groupadd -g $PGID abc && \
  useradd -u $PUID -g $PGID -d $HOME -s /bin/false abc

USER abc
CMD ["/bin/bash", "-c", "qbittorrent-nox --webui-port=8080"]
