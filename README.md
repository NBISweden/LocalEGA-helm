[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Build Status](https://travis-ci.com/NBISweden/LocalEGA-helm.svg?branch=master)](https://travis-ci.com/NBISweden/LocalEGA-helm)
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

Download the helm chart

```console
git clone https://github.com/NBISweden/LocalEGA-helm.git
```

Or

```console
helm repo add ega-charts https://nbisweden.github.io/LocalEGA-helm/
helm update
helm fetch --untar ega-charts/localega
```

*N.B:* If you use `git clone` to get the charts you will have to prefix `localega` in the example command lines below with `ega-charts/`.

When deploying a dev environment for the first time you need to create the secrets using the `legainit` utility from [LocalEGA-deploy-init](https://github.com/NBISweden/LocalEGA-deploy-init). Follow the instructions in that repository and install the command line utility. After it has been installed use:

```console
legainit --config-path localega/config
# legainit --config-path ega-charts/localega/config # If cloned with git
```

or if you want to include generate fake CEGA credentials use:

```console
legainit --cega --config-path localega/config
```

### Optional, add S3 storage

LocalEGA relies on a S3 type backend storage as data archive.  
If the kubernetes environment doesn't supply a S3 storage it can be added using either [minio](https://www.minio.io/) or [ceph](https://www.ceph.com).

#### Minio

See the [documentation](https://github.com/helm/charts/tree/master/stable/minio) for how to configure minio.  
More specifically the size of each backing volume and if minio should run in distributed mode or not.

If you set up all secrets with the `legainit` program grab the values for `S3_access` and `S3_secret` from the `localega/config/trace.yml` file.

```console
helm install --set accessKey=S3_access,secretKey=S3_secret,minioConfig.region=S3_region stable/minio
```

## Installing the Chart

Edit the values.yaml file and specify the relevant hostnames for cega-mq, cega-users, SQL and the relevant data_storage parts.

The values that has to be configured in values.yaml are:
 - `cega_users_host`
 - `cega_mq_host`
 - `cega_vhost`
 - `data_storage_url`
 - `data_storage_s3_bucket`
 - `data_storage_s3_region`
 - (possibly disable persistence)

You can then install the `localega` chart via Helm CLI:

```console
helm install --name <deployment name> --namespace <deployment namespace> localega -f localega/values.yaml -f localega/config/trace.yml
```

### Configuration

The following table lists the configurable parameters of the `localega` chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`config.broker_connection_attempts` | Connection attempts before timing out | `30`
`config.broker_enable_ssl` | Use SSl for broker connection | `false`
`config.broker_heartbeat` | Heartbeat timeout balue | `0`
`config.broker_port` | Local MQ acces port | `5672`
`config.broker_retry_delay` | time in seconds between each connection attempt | `10`
`config.broker_username` | username for accessing local MQ service | `guest`
`config.cega_users_host` | hostname of CEGA users service | `""`
`config.cega_mq_host` | CEGA MQ hostname | `""`
`config.cega_mq_ssl` | CEGA MQ uses SSL | `true`
`config.cega_vhost` | CEGA MQ vhost path | `""`
`config.cega_port` | CEGA MQ acces port | `5671`
`config.cega_mq_user` | CEGA MQ username | `""`
`config.cega_users_user` | CEGA users username | `""`
`config.postgres_pdata` | Path in container to postgres data folder location | `/ega`
`config.postgres_db_name` | Database name | `lega`
`config.postgres_host` | Database hostname or IP address | `Only needs to be set if the database is deployed searately`
`config.postgres_port` | Port to postgers service | `5432`
`config.postgres_sslmode` | Use SSL for Database connection | `prefer`
`config.postgres_try` | Number of times to retry | `5`
`config.postgres_try_interval` | Number of seconds between try attempts | `1`
`config.postgres_in_user` | Database username for ingestion | `lega_in`
`config.postgres_out_user` | Database username for outgestion | `lega_out`
`config.data_storage_type` | Backend storage type, `S3Storage` or `FileStorage` | `S3Storage`
`config.data_storage_url` | URL to S3 storage instance | `""`
`config.data_storage_s3_bucket` | S3 storage bucket | `""`
`config.data_storage_s3_region` | S3 storage region | `""`
`config.data_storage_s3_chunk_size` | S3 chunk size in MB | `16`
`config.data_storage_location` | Path to FileStorage volume | `/ega/data_archive`
`config.data_storage_mode` | File mode in storage volume | `2750`
`persistence.enabled` | If true, create a Persistent Volume Claim for all services that require it | `true`
`persistence.storageClass` | Storage Class for all Persistent volume Claims, use "local-storage" for local backed storage | `""`
`revisionHistory` | number of old ReplicaSets to retain to allow rollback | `3`
`secrets.cega_users_pass` | Password to CEGA users sevice | `""`
`secrets.cega_mq_pass` | Password for CEGA MQ service | `""`
`secrets.mq_pass` | Password for Localega MQ | `""`
`secrets.mq_password_hash` | Hashed password for Localega MQ | `""`
`secrets.pgp_passphrase` | private LocalEGA PGP passphrase | `""`
`secrets.shared_pgp_password` | Shared LocalEGA PGP password | `""`
`secrets.pg_in_password` | Password to LocalEGA sql database for ingestion | `""`
`secrets.pg_out_password` | Password to LocalEGA sql database for outgestion | `""`
`secrets.s3_access_key` | Access key to S3 storage | `""`
`secrets.s3_secret_key` | Secret key to S3 storage  | `""`
`secrets.token`| jwt token for testing file download via dataedge | ``
`dataedge.replicaCount` | desired number of replicas | `1`
`dataedge.repository` | dataedge container image repository | `cscfi/ega-dataedge`
`dataedge.imageTag` | dataedge container image version | `"latest"`
`dataedge.imagePullPolicy` | dataedge container image pull policy | `IfNotPresent`
`dataedge.port` | dataedge container port | `8080`
`dataedge.servicePort` | dataedge service port | `9059`
`filedatabase.replicaCount` | desired number of replicas | `1`
`filedatabase.repository` | filedatabase container image repository | `cscfi/ega-filedatabase`
`filedatabase.imageTag` | filedatabase container image version | `"latest"`
`filedatabase.imagePullPolicy` | filedatabase container image pull policy | `IfNotPresent`
`filedatabase.port` | filedatabase container port | `8080`
`filedatabase.servicePort` | filedatabase service port | `9050`
`filedatabase.debug` | filedatabase debug port | `5050`
`finalize.repository` | inbox container image repository | `egarchive/lega-base`
`finalize.imageTag` | inbox container image version | `stable`
`finalize.imagePullPolicy` | inbox container image pull policy | `IfNotPresent`
`inbox.repository` | inbox container image repository | `egarchive/lega-inbox`
`inbox.imageTag` | inbox container image version | `stable`
`inbox.imagePullPolicy` | inbox container image pull policy | `IfNotPresent`
`inbox.inboxPath` | Path on mounted volume for inbox data | `/`
`inbox.replicaCount` | desired number of inboxes | `1`
`inbox.persistence.existingClaim` | inbox data Persistent Volume existing claim name | `""`
`inbox.persistence.storageSize` | inbox persistent volume size | `1Gi`
`ingest.repository` | inbox container image repository | `egarchive/lega-base`
`ingest.imageTag` | inbox container image version | `stable`
`ingest.imagePullPolicy` | inbox container image pull policy | `IfNotPresent`
`ingest.replicaCount` | desired number of ingest workers | `1`
`keys.deploy` | Set to false if using a external keyserver | `true`
`keys.repository` | Keyserver container image repository | `cscfi/ega-keyserver`
`keys.imageTag` | Keyserver container image version | `"latest"`
`keys.imagePullPolicy` | Keyserver container image pull policy | `IfNotPresent`
`keys.port` | Keyserver port | `8080`
`keys.servicePort` | Keyserver service port | `9095`
`mq.repository` | rabbitmq container image repository | `egarchive/lega-mq`
`mq.imageTag` | rabbitmq container image pull policy | `stable`
`mq.imagePullPolicy` | rabbitmq container image pull policy | `IfNotPresent`
`mq.persistence.existingClaim` | rabbitmq data Persistent Volume existing claim name | `""`
`mq.persistence.storageSize` | rabbitmq persistent volume size | `1Gi`
`mq.port` | rabbitmq port | `5672`
`mq.metrics.enabled` | enable metrics for rabbirmq service | `true`
`mq.metrics.repository` | rabbitmq metrics exporter repository | `kbudde/rabbitmq-exporter`
`mq.metrics.imageTag` | rabbitmq metrics exporter version | `v0.29.0`
`mq.metrics.imagePullPolicy` | rabbitmq metrics exporter image pull policy | `IfNotPresent`
`postgres.deploy` | Set to false if using a external database | `true`
`postgres.repository` | postgreSQL container image repository | `egarchive/lega-db`
`postgres.imageTag` | postgreSQL container image version | `stable`
`postgres.imagePullPolicy` | postgreSQL container image pull policy | `IfNotPresent`
`postgres.persistence.existingClaim` | postgres data Persistent Volume existing claim name | `""`
`postgres.persistence.storageSize` | postgres persistent volume size | `1Gi`
`postgres.metrics.enabled` | enable metrics for postgreSQL service | `true`
`postgres.metrics.repository` | postgreSQL metrics exporter repository | `wrouesnel/postgres_exporter`
`postgres.metrics.imageTag` | postgreSQL metrics exporter version | `v0.4.6`
`postgres.metrics.imagePullPolicy` | postgreSQL metrics exporter image pull policy | `IfNotPresent`
`res.repository`| RES container image repository | `cscfi/ega-res`
`res.imageTag`| RES container image version | `"latest"`
`res.imagePullPolicy`| RES container image pull policy | `IfNotPresent`
`res.replicaCount`| desired number of RES containers | `1`
`res.port` | res container port | `8080`
`res.servicePort` | res service port | `9090`
`res.debug` | res debug port | `5058`
`verify.repository` | inbox container image repository | `egarchive/lega-base`
`verify.imageTag` | inbox container image version | `stable`
`verify.imagePullPolicy` | inbox container image pull policy | `IfNotPresent`
`verify.replicaCount`| desired number of verify containers | `1`
`tester.run`| run end-to-end test if true | `false`
`tester.repository` | inbox container image repository | `nbisweden/lega-tester`
`tester.imageTag` | inbox container image version | `latest`
`tester.imagePullPolicy` | inbox container image pull policy | `Always`

## Install fake CEGA

Unless you cloned the git repo you need to download the cega chart:

```console
helm fetch --untar ega-charts/cega
```

Copy the relevant files from the config folder created by the init script.

```console
cp localega/config/users.json localega/config/cega.* cega/conf
```

You can install the `cega` chart via Helm CLI:

```console
helm install --name <deployment name> --namespace <deployment namespace> cega -f localega/config/trace.yml
```

## Uninstalling the Chart

You can uninstall the Chart via Helm CLI:

```console
helm delete ${deployment name} --purge
```
