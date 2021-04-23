# import-osm-service

The service responsible to import POIs from several data sources

## Docker

This builds a docker image based on a specific version of osm2pgsql. The command to build is:

```bash
docker build --tag mapdiscover/import-service:latest --build-arg OSM2PGSQL_VERSION=1.4.1 .
```

```bash
docker run --rm -it --entrypoint /bin/bash mapdiscover/import-service:latest
```
