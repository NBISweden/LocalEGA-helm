# LocalEGA-helm

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![GitHub version](https://badge.fury.io/gh/NBISweden%2FLocalEGA-helm.svg)](https://badge.fury.io/gh/NBISweden%2FLocalEGA-helm)
![](https://github.com/NBISweden/LocalEGA-helm/workflows/Helm%20linter/badge.svg)
![](https://github.com/NBISweden/LocalEGA-helm/workflows/k3s%20deployment/badge.svg?event=pull_request)

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
 - `s3_archive_bucket`
 - `s3_archive_region`
 - (possibly disable persistence)

You can then install the `localega` chart via Helm CLI:

```console
helm install --name <deployment name> --namespace <deployment namespace> localega -f localega/values.yaml -f localega/config/trace.yml
```

### Configuration

#### localega chart

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
`config.s3_archive_url` | URL to S3 archive instance | `""`
`config.s3_archive_bucket` | S3 archive bucket | `""`
`config.s3_archive_region` | S3 archive region | `""`
`config.s3_archive_chunk_size` | S3 chunk size in MB | `16`
`config.data_storage_location` | Path to FileStorage volume | `/ega/data_archive`
`config.data_storage_mode` | File mode in storage volume | `2750`
`config.s3_inbox_backend_url` | URL to S3 inbox backend | `""`
`config.s3_inbox_backend_bucket` | S3 inbox backend bucket | `""`
`config.s3_inbox_backend_region` | S3 inbox backend region | `""`
`config.tls_certs` | boolean to create secrets that hold the TLS certificates | `true`
`config.tls_ca_root_file` | Name of the ca root file | `ca.crt`
`config.tls_cert_ending` | File ending to append after service name when loading TLS certificates | `.crt`
`config.tls_key_ending` | File ending to append after service name when loading TLS keys | `.key`
`persistence.enabled` | If true, create a Persistent Volume Claim for all services that require it | `true`
`persistence.storageClass` | Storage Class for all Persistent volume Claims, use "local-storage" for local backed storage | `""`
`revisionHistory` | number of old ReplicaSets to retain to allow rollback | `3`
`networkPolicy.create` | boolean that enables creation of network policies | `false`
`networkPolicy.cegaMqBroker` | block that specifies the egress rules for accessing the CEGA MQ server | `0.0.0.0/0`
`networkPolicy.postgres` | block that specifies the egress rules for accessing an external postgres server | `0.0.0.0/0`
`networkPolicy.S3Storage` | block that specifies the egress rules for accessing the external S3 server | `0.0.0.0/0`
`secrets.cega_users_pass` | Password to CEGA users sevice | `""`
`secrets.cega_mq_pass` | Password for CEGA MQ service | `""`
`secrets.mq_pass` | Password for Localega MQ | `""`
`secrets.mq_password_hash` | Hashed password for Localega MQ | `""`
`secrets.pgp_passphrase` | private LocalEGA PGP passphrase | `""`
`secrets.shared_pgp_password` | Shared LocalEGA PGP password | `""`
`secrets.pg_in_password` | Password to LocalEGA sql database for ingestion | `""`
`secrets.pg_out_password` | Password to LocalEGA sql database for outgestion | `""`
`secrets.s3_archive_access_key` | Access key to S3 archive | `""`
`secrets.s3_archive_secret_key` | Secret key to S3 archive | `""`
`secrets.token`| jwt token for testing file download via dataedge | ``
`secrets.s3_inbox_backend_access_key` | Access key to S3 inbox backend | `""`
`secrets.s3_inbox_backend_secret_key` | Secret key to S3 inbox backend | `""`
`ingress.deploy` | Create ingress for data out components when set to true | `false`
`ingress.hostname` | The hostname that will be used in the ingress path | `""`
`ingress.tls` | Boolean that controls whether TLS should be enabled for the ingress | `true`
`ingress.secretName` | Name of the secret that holds the TLS certificates, the secret must be manuallly created unless cert-manager is installed | `""`
`ingress.issuer` | Name of the issuer to use when requesting the TLS certifiactes, requires that `cert-manager` is installed and configured | `""`
`filedatabase_host` | External filedatabase host | `""`
`filedatabase_port` | External filedatabase port | `9059`
`keys_host` | External keys host | `""`
`keys_port` | External keys port | `9095`
`dataedge_host` | External dataedge host | `""`
`dataedge_port` | External dataedge port | `9050`
`res_host` | External res host | `""`
`res_port` | External res port | `9090`
`dataedge.deploy` | Set to false if not using a dataedge service | `true`
`dataedge.replicaCount` | desired number of replicas | `1`
`dataedge.repository` | dataedge container image repository | `cscfi/ega-dataedge`
`dataedge.imageTag` | dataedge container image version | `"latest"`
`dataedge.imagePullPolicy` | dataedge container image pull policy | `IfNotPresent`
`dataedge.keystorePass` | keystore password | `dataedge`
`dataedge.port` | dataedge container port | `8080`
`dataedge.servicePort` | dataedge service port | `9059`
`filedatabase.deploy` | Set to false if not using a filedatabase service | `true`
`filedatabase.replicaCount` | desired number of replicas | `1`
`filedatabase.repository` | filedatabase container image repository | `cscfi/ega-filedatabase`
`filedatabase.imageTag` | filedatabase container image version | `"latest"`
`filedatabase.imagePullPolicy` | filedatabase container image pull policy | `IfNotPresent`
`filedatabase.port` | filedatabase container port | `8080`
`filedatabase.servicePort` | filedatabase service port | `9050`
`filedatabase.debug` | filedatabase debug port | `5050`
`filedatabase.keystorePass` | keystore password | `filedatabase`
`finalize.deploy` | Set to false if not using a finalize service | `true`
`finalize.repository` | inbox container image repository | `egarchive/lega-base`
`finalize.imageTag` | inbox container image version | `stable`
`finalize.imagePullPolicy` | inbox container image pull policy | `IfNotPresent`
`inbox.deploy` | Set to false if not using a inbox service | `true`
`inbox.repository` | inbox container image repository | `egarchive/lega-inbox`
`inbox.imageTag` | inbox container image version | `stable`
`inbox.imagePullPolicy` | inbox container image pull policy | `IfNotPresent`
`inbox.inboxPath` | Path on mounted volume for inbox data | `/`
`inbox.replicaCount` | desired number of inboxes | `1`
`inbox.persistence.existingClaim` | inbox data Persistent Volume existing claim name | `""`
`inbox.persistence.storageSize` | inbox persistent volume size | `1Gi`
`inbox.keystorePass` | keystore password for the mina inbox | `inbox`
`ingest.deploy` | Set to false if not using a ingest service | `true`
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
`keys.keystorePass` | keystore password | `keys`
`mq.deploy` | Set to false if using an external message queue service | `true`
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
`res.deploy` | Set to false if not using a message re-encryption service | `true`
`res.repository`| RES container image repository | `cscfi/ega-res`
`res.imageTag`| RES container image version | `"latest"`
`res.imagePullPolicy`| RES container image pull policy | `IfNotPresent`
`res.replicaCount`| desired number of RES containers | `1`
`res.port` | res container port | `8080`
`res.servicePort` | res service port | `9090`
`res.debug` | res debug port | `5058`
`res.keystorePass` | keystore password | `res`
`s3inbox.deploy` | Set to true if an s3 inbox is to be used | `false`
`s3inbox.repository`| s3inbox container image repository | `nbisweden/ega-s3inbox`
`s3inbox.imageTag`| s3inbox container image version | `"0.1"`
`s3inbox.imagePullPolicy`| s3inbox container image pull policy | `Always`
`s3inbox.replicaCount`| desired number of s3inbox containers | `1`
`s3inbox.port` | s3inbox container port | `443`
`s3inbox.servicePort` | s3inbox service port | `443`
`s3inbox.use_credentials_file` | Set to true if a credentials file is used | `false`
`verify.deploy` | Set to false if not using a message verify service | `true`
`verify.repository` | inbox container image repository | `egarchive/lega-base`
`verify.imageTag` | inbox container image version | `stable`
`verify.imagePullPolicy` | inbox container image pull policy | `IfNotPresent`
`verify.replicaCount`| desired number of verify containers | `1`
`tester.run`| run end-to-end test if true | `false`
`tester.repository` | inbox container image repository | `nbisweden/lega-tester`
`tester.imageTag` | inbox container image version | `latest`
`tester.imagePullPolicy` | inbox container image pull policy | `Always`


#### logging chart

The following table lists the configurable parameters of the `logging` chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`config.broker_connection_attempts` | Connection attempts before timing out | `30`
`config.elastichost` | Hostname for the Elasticsearch master | `elasticsearch-master.elasticsearch`
`config.elasticport` | Port for connecting to the elsaticsearch master | `9200`
`fluentbit.name` | Value for label `component` |  `fluentbit`
`fluentbit.deploy` | Set to false to not deploy fluentbit | `true`
`fluentbit.repository` | fluentbit container image repository | `true`
`fluentbit.imageTag` | fluentbit container image version | `1.3.3`
`fluentbit.imagePullPolicy` | fluentbit container image pull policy | `Always`


## Install fake CEGA

Unless you cloned the git repo you need to download the cega chart:

```console
helm fetch --untar ega-charts/cega
```

Copy the relevant files from the config folder created by the init script.

```console
cp localega/config/users.json localega/config/cega.* cega/config
mkdir cega/config/certs
cp localega/config/certs/{cega-*,root.ca.crt} cega/config/certs/
```

You can install the `cega` chart via Helm CLI:

```console
helm install --name <deployment name> --namespace <deployment namespace> cega -f localega/config/trace.yml
```


## Setup logging

See the [logging readme](logging.md).


## Uninstalling the Chart

You can uninstall the Chart via Helm CLI:

```console
helm delete ${deployment name} --purge
```
