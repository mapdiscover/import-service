# import-osm-service

The service responsible to import POIs from OSM

## Docker

This builds a docker image based on a specific version of osm2pgsql. The command to build is:

`docker build --tag mapdiscover/import-osm-service:1.4.1 --build-arg OSM2PGSQL_VERSION=1.4.1 .`
