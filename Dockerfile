FROM debian:buster-slim
ARG OSM2PGSQL_VERSION=1.4.1

ENV PBF_PATH /input/source.osm.pbf
ENV REPLICATION_BASE_URL https://planet.openstreetmap.org/replication/minute/

ENV OSM2PGSQL_ARGUMENTS ""

ENV POSTGRES_PREFIX planet_osm
ENV POSTGRES_HOST postgres
ENV POSTGRES_PORT 3306
ENV POSTGRES_DATABASE osm2pgsql
ENV POSTGRES_USERNAME osm2pgsql
ENV POSTGRES_PASSWORD osm2pgsql

RUN apt-get update && apt-get install -y osm2pgsql=${OSM2PGSQL_VERSION}

COPY ./scripts/ /scripts/
COPY ./processor/ /processor/

ENTRYPOINT [ "/scripts/osm2pgsql-docker", "start" ]