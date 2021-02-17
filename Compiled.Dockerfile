# Base image
FROM debian:buster-slim AS base
# FROM debian:buster-slim
ARG OSM2PGSQL_VERSION=1.4.1
ARG OSM2PGSQL_LUAJIT=ON

ENV PBF_PATH /input/source.osm.pbf
ENV REPLICATION_BASE_URL https://planet.openstreetmap.org/replication/minute/

ENV OSM2PGSQL_ARGUMENTS ""

ENV POSTGRES_PREFIX planet_osm
ENV POSTGRES_HOST postgres
ENV POSTGRES_PORT 3306
ENV POSTGRES_DATABASE osm2pgsql
ENV POSTGRES_USERNAME osm2pgsql
ENV POSTGRES_PASSWORD osm2pgsql

# Do the build
FROM debian:buster-slim AS build
WORKDIR /src
RUN sudo apt-get update && apt-get install -y git
RUN git clone https://github.com/openstreetmap/osm2pgsql
RUN cd osm2pgsql
RUN git checkout $OSM2PGSQL_VERSION

RUN sudo apt-get install -y make cmake g++ libboost-dev libboost-system-dev \
  libboost-filesystem-dev libexpat1-dev zlib1g-dev \
  libbz2-dev libpq-dev libproj-dev lua5.3 liblua5.3-dev pandoc \
  libluajit-5.1-dev

RUN mkdir build && cd build
RUN cmake -D WITH_LUAJIT=$OSM2PGSQL_LUAJIT ..

RUN make

FROM base AS final

#RUN apt-get update && apt-get install osm2pgsql=${OSM2PGSQL_VERSION}
ENTRYPOINT [ "/wrapper/osm2pgsql-docker-wrapper", "start" ]