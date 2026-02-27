# IBM DataPower Nano Operator

This Helm chart deploys the IBM DataPower Nano Operator to a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.32+
- Gateway API v1.2.1 standard channel (see below)
- IBM Entitlement Key (for pulling images from `cp.icr.io`)
- Helm 3+

### Gateway API

IBM DataPower Nano Operator depends on [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/) CRDs being available in the cluster. If you do not already have Gateway API installed on your cluster, you can do so via:

```
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```

See the upstream Kubernetes docs on [Installing Gateway API](https://gateway-api.sigs.k8s.io/guides/getting-started/#installing-gateway-api) for reference.


## Configuration

The following table lists the configurable parameters of the IBM DataPower Nano Operator chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image repository | `cp.icr.io/cp/datapower/datapower-nano-operator` |
| `image.tag` | Container image tag | `build.248` |
| `image.digest` | Container image digest (optional, overrides tag) | n/a |
| `imagePullSecrets` | Image pull secrets for authenticated registries | `[{name: ibm-entitlement-key}]` |
| `imagePullPolicy` | Container image pull policy | `IfNotPresent` |

## Installing

### Check for CRDs

If IBM DataPower Nano Operator had been installed previously on the cluster, it's possible that its CustomResourceDefinitions (CRDs) are still present. To check if the CRDs are present, run the following command:

```
kubectl get crd | grep 'nano.datapower.ibm.com'
```

If any CRDs are present, they will **not** be updated during `helm install` or `helm upgrade`. You must manually update the CRDs:

```
kubectl apply --server-side --force-conflicts -f crds/nano.datapower.ibm.com.yaml
```

### Create namespace

Create a new namespace for the IBM DataPower Nano Operator installation. The Operator is cluster-scoped, so it is a best practice to install it in its own namespace.

In the below example, the namespace name is `datapower-nano-system`, but you can customize this if you wish. Subsequent steps will use `datapower-nano-system` as the example.

```
kubectl create ns datapower-nano-system
```

### Create image pull secret

IBM DataPower Nano Gateway images (including the Operator) reside in IBM Entitled Registry (`cp.icr.io`), which requires authentication. If you are installing from this registry, you will need to create a Secret with credentials to authenticate. If you are using a private registry, consult your cluster admins to understand how to configure an image pull secret for your environment. The below example assumes `cp.icr.io` is being used.

Create a Secret with your IBM Entitlement Key in the namespace you just created.

In the below example, `ibm-entitlement-key` is the name of the Secret. If you use a different name, be sure to update `imagePullSecrets` in `values.yaml` accordingly.

```
kubectl create -n datapower-nano-system secret \
    docker-registry \
    ibm-entitlement-key \
    --docker-username=cp \
    --docker-password=<entitlement-key> \
    --docker-server=cp.icr.io
```

### Install the chart

Prior to installing the chart, adjust `values.yaml` as desired. When you're ready, install the chart in the namespace you created above.

```bash
helm install -n datapower-nano-system datapower-nano-operator .
```

`datapower-nano-operator` is the Helm release name, you can customize this if you wish. This name will be used in subsequent operations like upgrading or uninstalling.

`.` implies that the `helm install` command is being run in the same directory as this README. If you are running from a different directory, adjust the path accordingly.

## Upgrading

### Upgrade the CRDs

`helm upgrade` will not apply the CRDs, so you will need to apply them manually.

```
kubectl apply --server-side --force-conflicts -f crds/nano.datapower.ibm.com.yaml
```

### Upgrade the chart
You can use `helm upgrade` to upgrade to a new chart version, or to modify an existing release using `values.yaml`. To upgrade an existing Helm release of IBM DataPower Nano Operator, confirm the namespace and name of the release using `helm list`:

```
helm list
```

The following example will use namespace `datapower-nano-system` and release name `datapower-nano-operator`. The `helm upgrade` is equivalent to `helm install` that was done above (same arguments):

```
helm upgrade -n datapower-nano-system datapower-nano-operator .
```

## Uninstalling

To uninstall the IBM DataPower Nano Operator release (deployment, etc.):

```bash
helm uninstall -n datapower-nano-system datapower-nano-operator
```

### Removing CRDs

`helm uninstall` does not delete the CRDs. You can manually delete them via:

```
kubectl delete -f crds/nano.datapower.ibm.com.yaml
```
