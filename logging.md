# Logging with fluentbit

## Install the elasticsearch helm chart

```bash
helm install --namespace elasticsearch --name elasticsearch elastic/elasticsearch --values elasticsearch-conf.yaml
```

I used the following values:

```yaml
---
# Permit co-located instances for solitary minikube virtual machines.
antiAffinity: "soft"

# Shrink default JVM heap.
esJavaOpts: "-Xmx128m -Xms128m"

# Allocate smaller chunks of memory per pod.
resources:
  requests:
    cpu: "100m"
    memory: "512M"
  limits:
    cpu: "1000m"
    memory: "512M"

# Request smaller persistent volumes.
volumeClaimTemplate:
  accessModes: [ "ReadWriteMany" ]
  storageClassName: "nfs"
  resources:
    requests:
      storage: 100M
```


## Install fluentbit

The defaults assume that elasticsearch is installed with the above helm chart
in the elasticsearch namespace.

```bash
helm install --namespace fluentbit --name fluentbit ega-charts/logging
```
