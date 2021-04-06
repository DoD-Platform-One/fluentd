# fluentd-aggregator

This is a fluentd container that can be used as a central aggregation point for multiple log sources and destinations.

This was originally pulled from the ironbank fluentd image found [here](#TODO add link).

This directory structure/way of building the docker image is in line with how IB builds it's images.

## Usage

* ensure you have a local downloads folder in this directory

```shell
cd fluentd/docker
```

* pull all the gem dependencies

```shell
cat hardening_manifest.yaml| yq e '.resources[].url' - | wget -N -i - -P ./downloads 
```

* ensure that those packages/binaries were downloaded

```shell
ls downloads
```

* build the docker container

```shell
docker build . -t registry.dso.mil/platform-one/big-bang/apps/sandbox/fluentd:<some-tag>
```

* push the image up to the repo

```shell
docker push registry.dso.mil/platform-one/big-bang/apps/sandbox/fluentd:<some-tag>
```
