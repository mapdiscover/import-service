FROM python:3-slim-buster

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
RUN git clone https://github.com/openstreetmap/osm2pgsql
RUN cd osm2pgsql
RUN git checkout $OSM2PGSQL_VERSION

RUN apt-get install -y make cmake g++ libboost-dev libboost-system-dev \
  libboost-filesystem-dev libexpat1-dev zlib1g-dev \
  libbz2-dev libpq-dev libproj-dev lua5.3 liblua5.3-dev pandoc \
  libluajit-5.1-dev

RUN mkdir build && cd build
RUN cmake -D WITH_LUAJIT=$OSM2PGSQL_LUAJIT ..

RUN make
RUN make install

RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY ./scripts/ /scripts/
COPY ./processor/ /processor/

ENTRYPOINT [ "/wrapper/osm2pgsql-docker-wrapper", "start" ]