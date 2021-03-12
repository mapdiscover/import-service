FROM debian:buster-slim

ARG OSM2PGSQL_VERSION=1.4.1
ARG OSM2PGSQL_LUAJIT=ON

ENV OSM_FILE /input/source.osm.pbf
ENV REPLICATION_URL https://planet.openstreetmap.org/replication/minute/
ENV REPLICATION_CMD /scripts/osm2pgsql-replication

ENV OSM2PGSQL_ARGUMENTS ""

ENV POSTGRES_PREFIX planet_osm
ENV POSTGRES_HOST postgres
ENV POSTGRES_PORT 3306
ENV POSTGRES_DB osm2pgsql
ENV POSTGRES_USER osm2pgsql
ENV POSTGRES_PASSWORD osm2pgsql

RUN apt-get update && apt-get install -y git make cmake g++ libboost-dev \
  libboost-system-dev libboost-filesystem-dev libexpat1-dev \
  zlib1g-dev libbz2-dev libpq-dev libproj-dev lua5.3 liblua5.3-dev \
  libluajit-5.1-dev pandoc \
  python3 python3-pip \
  # wget unzip \
  lua-dkjson \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone https://github.com/openstreetmap/osm2pgsql .
RUN git checkout tags/$OSM2PGSQL_VERSION

WORKDIR /src/build
RUN cmake -D WITH_LUAJIT=$OSM2PGSQL_LUAJIT ..
RUN NB_CORES=$(grep -c '^processor' /proc/cpuinfo) \
  && make -j$((NB_CORES+1)) -l${NB_CORES} \
  && make install

RUN rm -rf /src

# RUN wget -O luarocks.tar.gz https://luarocks.org/releases/luarocks-3.3.1.tar.gz \
#   && tar zxpf luarocks.tar.gz && rm luarocks.tar.gz && cd luarocks-* \
#   && ./configure \
#   && make \
#   && make install

# WORKDIR /processor
# RUN luarocks install dkjson \
#  && luarocks install inspect

WORKDIR /scripts
RUN pip3 install osmium psycopg2

COPY ./scripts/ /scripts/
COPY ./processor/ /processor/

ENTRYPOINT [ "/scripts/osm2pgsql-docker", "--verbose", "--output=flex --style=/processor/main.lua" ]