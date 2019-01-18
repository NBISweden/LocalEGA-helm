[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Build Status](https://travis-ci.org/NBISweden/LocalEGA-helm.svg?branch=master)](https://travis-ci.org/NBISweden/LocalEGA-helm)
[![GitHub version](https://badge.fury.io/gh/NBISweden%2FLocalEGA-helm.svg)](https://badge.fury.io/gh/NBISweden%2FLocalEGA-helm)

# LocalEGA-helm

## Table of Contents

- [Prerequisites](#Prerequisites)
  - [Optional, add S3 storage](#Optional-add-S3-storage)
- [Installing the Chart](#Installing-the-Chart)
  - [Configuration](#Configuration)
- [Uninstalling the Chart](#Uninstalling-the-Chart)

Helm chart to deploy LocalEGA to any kubernetes cluster.

## Prerequisites

Before deploying the Helm charts HELM should be initialized and the tiller installed, following [these](https://docs.helm.sh/using_helm#initialize-helm-and-install-tiller) instructions.

When deploying a dev environment for the first time you need to create the secrets using the `deploy.py` script from [LocalEGA-deploy-k8s](https://github.com/NBISweden/LocalEGA-deploy-k8s).

```console
python3 {/PATH/TO/LocalEGA-deploy-k8s}/auto/deploy.py --config-path localega/
```

### Optional, add S3 storage

LocalEGA relies on a S3 type backend storage as data archive.  
If the kubernetes environment doesn't supply a S3 storage it can be added using either [minio](https://www.minio.io/) or [ceph](https://www.ceph.com).

#### Minio

See the [documentation](https://github.com/helm/charts/tree/master/stable/minio) for how to configure minio.  
More specifically the size of each backing volume and if minio should run in distributed mode or not.

```console
helm install --namespace localega --set accessKey=S3_access,secretKey=S3_secret,minioConfig.region=S3_region stable/minio
```

## Installing the Chart

To be able to deploy Helm charts from this repository, you should first run the following command:

```console
helm repo add ega-charts https://nbisweden.github.io/LocalEGA-helm/
```

Find out the latest chart version by using:

```console
helm search | grep ega-charts/localega
```

You can install the `localega` chart via Helm CLI:

```console
helm install --version <chart-version> --name localega --namespace localega --values localega/config/trace.yml ega-charts/localega
```

### Configuration

The following table lists the configurable parameters of the `localega` chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`base.repository` | LocalEGA container image repository | `nbisweden/ega-base`
`base.imageTag` | LocalEGA container image tag | `latest`
`base.imagePullPolicy` | LocalEGA container image pull policy | `IfNotPresent`
`config.deploy` | If true, deploy ConfigMaps | `true`
`config.broker_connection_attempts` | Connection attempts before timing out | `30`
`config.broker_retry_delay` | time in seconds between each connection attempt | `10`
`config.broker_username` | username for accessing local MQ service | `""`
`config.cega_endpoint` | URL to CEGA user service | `""`
`config.cega_endpoint_json` | Prefix in the JSON response that contains the user info| `response.result`
`config.cega_mq_host` | CEGA MQ hostname | `""`
`config.cega_vhost` | CEGA MQ vhost path | `""`
`config.cega_port` | CEGA MQ acces port | `5271`
`config.cega_username` | CEGA MQ username | `""`
`config.postgres_db_name` | Database name | `lega`
`config.postgres_host` | Database hostname or IP address | `""`
`config.postgres_try` | Database connection attempts | `30`
`config.postgres_user` | Database username | `""`
`config.data_storage_type` | Backend storage type, `S3Storage` or `file` | `S3Storage`
`config.data_storage_url` | URL to backed storage | `""`
`persistence.enabled`| If true, create a Persistent Volume Claim for all services that require it| `true`
`persistence.storageClass` | Storage Class for all Persistent volume Claims, use "local-storage" for local backed storage | `""`
`secrets.deploy` | If true, deploy secrets | `true`
`secrets.keys_password` | Shared LocalEGA PGP password | `""`
`secrets.lega_password` | LocalEGA password | `""`
`secrets.postgres_password` | Password to LocalEGA sql database | `""`
`secrets.s3_access` | Access key to S3 storage | `""`
`secrets.s3_secret` | Secret key to S3 storage  | `""`
`dataedge.name` | dataedge conataimer name | `dataedge`
`dataedge.replicaCount` | desired number of replicas | `1`
`dataedge.repository` | dataedge container image repository | `cscfi/ega-dataedge`
`dataedge.imageTag` | dataedge container image version | `"1.0"`
`dataedge.imagePullPolicy` | dataedge container image pull policy | `IfNotPresent`
`dataedge.port` | dataedge container port | `8080`
`dataedge.servicePort` | dataedge service port | `9059`
`dataedge.debug` | dataedge debug port | `5058`
`dataedge.logpath` | dataedge log path | `"/tmp/logs"`
`filedatabase.name` | filedatabase conataimer name | `filedatabase`
`filedatabase.replicaCount` | desired number of replicas | `1`
`filedatabase.repository` | filedatabase container image repository | `cscfi/ega-filedatabase`
`filedatabase.imageTag` | filedatabase container image version | `"1.0"`
`filedatabase.imagePullPolicy` | filedatabase container image pull policy | `IfNotPresent`
`filedatabase.port` | filedatabase container port | `8080`
`filedatabase.servicePort` | filedatabase service port | `9050`
`filedatabase.debug` | filedatabase debug port | `5050`
`inbox.name` | inbox container name | `inbox`
`inbox.repository` | inbox container image repository | `nbisweden/ega-inbox`
`inbox.imageTag` | inbox container image version | `latest`
`inbox.imagePullPolicy` | inbox container image pull policy | `IfNotPresent`
`inbox.inboxPath` | Path on mounted volume for inbox data | `/`
`inbox.replicaCount` | desired number of inboxes | `1`
`inbox.persistence.existingClaim` | inbox data Persistent Volume existing claim name | `""`
`inbox.persistence.storageSize` | inbox persistent volume size | `1Gi`
`ingest.name` | ingest container name | `ingest`
`ingest.replicaCount` | desired number of ingest workers | `1`
`keys.deploy` | Set to false if using a external keyserver | `true`
`keys.repository` | Keyserver container image repository | `cscfi/ega-keyserver`
`keys.imageTag` | Keyserver container image version | `"1.0"`
`keys.imagePullPolicy` | Keyserver container image pull policy | `IfNotPresent`
`keys.port` | Keyserver port | `8443`
`mq.name` | rabbitmq container name | `rabbitmq`
`mq.repository` | rabbitmq container image repository | `rabbitmq`
`mq.imageTag` | rabbitmq container image pull policy | `3.6-management-alpine`
`mq.imagePullPolicy` | rabbitmq container image pull policy | `IfNotPresent`
`mq.persistence.existingClaim` | rabbitmq data Persistent Volume existing claim name | `""`
`mq.persistence.storageSize` | rabbitmq persistent volume size | `1Gi`
`mq.replicaCount` | desired number of rabbitmqes | `1`
`mq.port` | rabbitmq port | `5672`
`mq.metrics.enabled` | enable metrics for rabbirmq service | `true`
`mq.metrics.repository` | rabbitmq metrics exporter repository | `kbudde/rabbitmq-exporter`
`mq.metrics.imageTag` | rabbitmq metrics exporter version | `v0.29.0`
`mq.metrics.imagePullPolicy` | rabbitmq metrics exporter image pull policy | `IfNotPresent`
`postgres.deploy` | Set to false if using a external database | `true`
`postgres.name` | postgreSQL container name | `postgres`
`postgres.repository` | postgreSQL container image repository | `postgres`
`postgres.imageTag` | postgreSQL container image version | `10.5-apline`
`postgres.imagePullPolicy` | postgreSQL container image pull policy | `IfNotPresent`
`postgres.persistence.existingClaim` | postgres data Persistent Volume existing claim name | `""`
`postgres.persistence.storageSize` | postgres persistent volume size | `1Gi`
`postgres.replicaCount` | desired number of postgreses | `1`
`postgres.metrics.enabled` | enable metrics for postgreSQL service | `true`
`postgres.metrics.repository` | postgreSQL metrics exporter repository | `wrouesnel/postgres_exporter`
`postgres.metrics.imageTag` | postgreSQL metrics exporter version | `v0.4.6`
`postgres.metrics.imagePullPolicy` | postgreSQL metrics exporter image pull policy | `IfNotPresent`
`res.name` | RES container name | `res`
`res.repository`| RES container image repository | `cscfi/ega-res`
`res.imageTag`| RES container image version | `"1.0"`
`res.imagePullPolicy`| RES container image pull policy | `IfNotPresent`
`res.replicaCount`| desired number of RES containers | `1`
`res.port` | res container port | `8080`
`res.servicePort` | res service port | `9090`
`res.debug` | res debug port | `5058`
`verify.name` | verify container name | `verify`
`verify.replicaCount`| desired number of verify containers | `1`

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install --version <chart-version> --name localega --namespace localega --set postgres.imageTag=10 --values localega/config/trace.yml ega-charts/localega

```

## Install fake CEGA

Find out the latest chart version by using:

```console
helm search | grep ega-charts/cega
```

You can install the `cega` chart via Helm CLI:

```console
helm install --version <chart-version> --name cega --namespace localega --values localega/config/trace.yml ega-charts/cega
```

## Uninstalling the Chart

You can uninstall the Chart via Helm CLI:

```console
helm delete ${deployment name} --purge
```
