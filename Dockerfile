FROM python:3-slim-buster AS build

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

WORKDIR /src

RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/openstreetmap/osm2pgsql .
RUN git checkout tags/$OSM2PGSQL_VERSION

RUN apt-get install -y make cmake g++ libboost-dev libboost-system-dev \
  libboost-filesystem-dev libexpat1-dev zlib1g-dev \
  libbz2-dev libpq-dev libproj-dev lua5.3 liblua5.3-dev pandoc \
  libluajit-5.1-dev

WORKDIR /src/build
RUN cmake -D WITH_LUAJIT=$OSM2PGSQL_LUAJIT ..

RUN make
RUN make install

RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /src

FROM debian:buster-slim AS base

COPY --from=build /usr/local/bin/osm2pgsql /usr/local/bin/osm2pgsql

RUN apt-get update && apt-get install --no-install-recommends -y debhelper cmake libboost-dev \
  libboost-system-dev libboost-filesystem-dev libbz2-dev libexpat1-dev \
  libosmium2-dev libpq-dev libproj-dev zlib1g-dev liblua5.3-dev lua5.3 \
  libluajit-5.1-dev python3 python3-psycopg2 python-pip

RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN pip install osmium

COPY ./scripts/ /scripts/
COPY ./processor/ /processor/

# ENTRYPOINT [ "/bin/bash" ]
ENTRYPOINT [ "/scripts/osm2pgsql-docker", "--dry-run -- --output=flex  --style='/processor/main.lua'" ]