FROM debian:latest

ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

RUN apt-get update && apt-get install -y \
  s6 \
  git \
  wget \
  build-essential \
  cmake \
  openssl \
  libboost-dev \
  qbittorrent-nox \
  qbittorrent \
  && rm -rf /var/lib/apt/lists/*

RUN git clone --recurse-submodules https://github.com/arvidn/libtorrent.git
COPY write_piece.patch /libtorrent/write_piece.patch
WORKDIR /libtorrent
RUN git apply write_piece.patch
RUN mkdir build
WORKDIR /libtorrent/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17 -DCMAKE_CXX_STANDARD_REQUIRED=ON -DCMAKE_CXX_EXTENSIONS=OFF ..
RUN make -j$(nproc)
RUN make install

COPY root/ /
EXPOSE 8080 6881 6881/udp
VOLUME /config
