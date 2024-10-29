# RED block CSI Driver over NVMEoF
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)

This is a **development branch**, for the most recent stable version see "Supported versions".

## Overview
The RED Container Storage Interface (CSI) Driver provides a CSI interface used by Container Orchestrators (CO) to manage the lifecycle of RED cluster's  volumes over NVMEoF protocol.

## Supported kubernetes versions matrix

|     K8S Version   | RED CSI Block driver version| 
|-------------------|----------------|
| Kubernetes >=1.22 | v1.0.1 [repository](https://github.com/DDNStorage/red-csi-driver-block/tree/v1.0.1) |

All releases will be stored here - [https://quay.io/repository/red/csi-driver-block](https://quay.io/repository/red/csi-driver-block)

## Feature List
|Feature|Feature Status|CSI Driver Version|Kubernetes Version| Implemented |
|--- |--- |--- |--- |--- |
|Static Provisioning|GA|>= v1.0.1|>=1.22| yes |
|Dynamic Provisioning|GA|>= v1.0.1|>=1.22| yes |
|RW mode|GA|>= v1.0.1|>=1.22| yes |
|RO mode|GA|>= v1.0.1|>=1.22| yes |
|Raw block device|GA|>= v1.0.1|>=1.22| yes |
|StorageClass Secrets|Beta|>= v1.0.1|>=1.22| yes |
|Expand volume|GA|>= v1.0.1|>=1.22| yes |
<!--
|Creating and deleting snapshot|GA|>= v1.0.0|>= v1.0.0|>=1.17|
|Provision volume from snapshot|GA|>= v1.0.0|>= v1.0.0|>=1.17|
|List snapshots of a volume|Beta|>= v1.0.0|>= v1.0.0|>=1.17|
-->



## Requirements

- Kubernetes cluster must allow privileged pods, this flag must be set for the API server and the kubelet
  ([instructions](https://github.com/kubernetes-csi/docs/blob/735f1ef4adfcb157afce47c64d750b71012c8151/book/src/Setup.md#enable-privileged-pods)):
  ```
  --allow-privileged=true
  ```
- Required the API server and the kubelet feature gates
  ([instructions](https://github.com/kubernetes-csi/docs/blob/735f1ef4adfcb157afce47c64d750b71012c8151/book/src/Setup.md#enabling-features)):
  ```
  --feature-gates=VolumeSnapshotDataSource=true,VolumePVCDataSource=true,ExpandInUsePersistentVolumes=true,ExpandCSIVolumes=true,ExpandPersistentVolumes=true,CSINodeInfo=true
  ```
  
`GA after` contains the last Kubernetes release in which you can still use a feature gate.

|    Feature   | GA after  | 
|-------------------|----------------|
| VolumePVCDataSource | 1.21 | 
| VolumeSnapshotDataSource | 1.22 | 
| CSINodeInfo | 1.22 |
| ExpandCSIVolumes | 1.26 |
| ExpandInUsePersistentVolumes | 1.26 |
  
- Mount propagation must be enabled, the Docker daemon for the cluster must allow shared mounts
  ([instructions](https://github.com/kubernetes-csi/docs/blob/735f1ef4adfcb157afce47c64d750b71012c8151/book/src/Setup.md#enabling-mount-propagation))

## Installation

1. Clone driver repository
   ```bash
   git clone https://github.com/DDNStorage/red-csi-driver-block.git
   cd red-csi-driver-block
   git checkout main
   ```
2. Prepare kubernetes host(s) - install nvme tools and enable nvme TCP kernel module
   ```bash
   apt -y install linux-modules-extra-$(uname -r)
   apt install nvme-cli
   modprobe nvme-tcp
   ```

3. Edit `deploy/kubernetes/red-csi-driver-block-config.yaml` file. Driver configuration example:
   ```yaml
   accounts:
     clu1/red/csiAccount:                                       # [required] config section key is path to service account <cluster>/<tenant>/<service account name>
       apis:
         - https://<RED API IP or FQDN>:443                       # [required] Red cluster REST API endpoint(s)
       password:  1234                                            # [required] Red cluster REST API password
     clu1/otherTenant/csiAccount:
       apis: https://10.3.4.4:443                                 # [required] Red cluster REST API endpoint(s)
       password:  1234                                            # [required] Red cluster REST API password
   ```
  **Note** : List of available configuration parameters in configuration section - [Defaults and params](#Defaults/Configuration/Parameter-options)

4. Create Kubernetes namespace:
    ```bash
   kubectl create namespace red-block-csi
   ```
5. Create Kubernetes secret from the file:
   ```bash
   kubectl create secret generic red-csi-driver-block-config --from-file=deploy/kubernetes/red-csi-driver-block-config.yaml -n red-block-csi
   ```
6. Register driver to Kubernetes:
   ```bash
   kubectl apply -f deploy/kubernetes/red-csi-driver-block.yaml
   ```
7. Installation is done

## Defaults/Configuration/Parameter options

| Default  | Config               |  Parameter    |  Desc                             |
|----------|----------------------|---------------|-----------------------------------|
|   -      | apis                 |      -        | List of RED API entrypoints      |
|   -      | password             |      -        | RED API user password             |
|   -      | zone                 |      -        | Zone to match topology.kubernetes.io/zone            |
|   -      | insecureSkipVerify   |      -        | TLS certificates check will be skipped when `true` (default: 'true')  |
|   []     | default_instance_ids |   instances   | Red cluster instance IDs to expose|
|   4420   | default_data_port    |   dataport    | Volume expose port                |
|   -      | owneruid             |   owneruid    | custom user uid (numeric)         |
|   -      | groupuid             |   groupuid    | custom group uid (numeric)        |
|   -      | perms                |   perms       | custom permissions (octal)        |
|   -      |                      |   account     | configuration account path (cluster/tenant/serviceAccountName) |
|   -      |                      |   service     | red service path (subtenant/serviceName) |


**Note**: all default parameters (`Default`) may be overwritten in RED CSI driver configuration or by specific _StorageClass_ or PV configuration parameters.

**Note**: `default_instance_ids` CSI driver config parameter is []int. Provides default volume allocation for expose. 

**Note**: `instances` parameter is string with ',' delimeter. It could be changed when `Distribution policy` be implemented.

**Note**: `owneruid` and `groupuid` must be defined together as numeric values in string representation

**Note**: `perms` must be octal value in string representation

## Update RED Block CSI driver configuration/secret

To update already existing RED Block CSI driver configuration stored in k8s secret

```bash
kubectl create secret generic red-csi-driver-block-config --save-config --dry-run=client --from-file=deploy/kubernetes/red-csi-driver-block-config.yaml -n red-block-csi -o yaml | kubectl apply -f -
```

**Note** The driver periodically (every 3 seconds) checks the configuration for changes but secret to host propagation could take some additional time

**Node** Do not delete secret's configuration section if there are volumes related to this section are exist. Need to delete volumes first

---

## Controller redundancy

Configuring multiple controller volume replicas
We can configure this by changing the deploy/kubernetes/red-csi-driver-block.yaml:

change the following line in controller service config
```
kind: StatefulSet
apiVersion: apps/v1
metadata:
name: red-block-csi-controller
spec:
serviceName: red-block-csi-controller-service
replicas: 1  # Change this to 2 or more.
```

RED CSI driver's pods should be running after installation:

```bash
$ kubectl get pods
red-block-csi-controller-0   4/4     Running   0          23h
red-block-csi-controller-1   4/4     Running   0          23h
red-block-csi-node-6cmsj     2/2     Running   0          23h
red-block-csi-node-wcrgk     2/2     Running   0          23h
red-block-csi-node-xtmgv     2/2     Running   0          23h
```

## Storage class parameters
Storage classes provide the capability to define parameters per storageClass instead of using config values [Defaults and params](#Defaults/Configuration/Parameter-options)

This is very useful to provide flexibility while using the same driver.

For example, we can use one storageClass to create volume.

A couple of possible use cases :

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: red-block-csi-driver-static-target-tg
provisioner: block.csi.red.ddn.com
allowVolumeExpansion: true
parameters:
  account: "clu1/red/csiAccount"
  service: "red/csiService"
``` 

Where:
  - `account` - exact RED service account path (<cluster/tenant/serviceAccountName>)
  - `service` - exact RED service path (<subtenant/serviceName>)

[Full list of default values and parameters](#defaults/configuration/parameter-options)


## Usage

**_NOTE:_** accessModes: `ReadWriteMany` cannot be run with volumeMode: `Filesystem`.

### Dynamically provisioned volumes

For dynamic volume provisioning, the administrator needs to set up a _StorageClass_ pointing to the driver.
In this case Kubernetes generates volume name automatically (for example `pvc-red-cfc67950-fe3c-11e8-a3ca-005056b857f8`).
Default driver configuration may be overwritten in `parameters` section:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: red-csi-driver-block-sc-nginx-dynamic
provisioner: block.csi.red.ddn.com
mountOptions:                        # list of options for `mount -o ...` command
#  - noatime                         #
#- matchLabelExpressions:            # use to following lines to configure topology by zones
#  - key: topology.kubernetes.io/zone
#    values:
#    - us-east
parameters:
  account: "clu1/red/csiAccount"    # [REQUIRED] exact RED service account path (<cluster/teant/serviceAccountName>)
  service: "red/csiService"         # [REQUIRED] exact RED service path (<subtenant/serviceName>)
```

#### Parameters

| Name           | Description                                            | Example                                               |
|----------------|--------------------------------------------------------|-------------------------------------------------------|
| `account`      | RED CSI driver configuration key as well path to service account | `clu1/red/csiAccount`                                        |
| `service`      | Exact RED service path (<subtenant/serviceName>) | `red/csiService`                                        |

#### Example

Run Nginx pod with dynamically provisioned volume:

```bash
kubectl apply -f examples/kubernetes/nginx-dynamic-volume.yaml

# to delete this pod:
kubectl delete -f examples/kubernetes/nginx-dynamic-volume.yaml
```

### Pre-provisioned volumes

The driver can use already existing RED volumes that has exports (automatic export will be added soon)
in this case, _StorageClass_, _PersistentVolume_ and _PersistentVolumeClaim_ should be configured.

#### _StorageClass_ configuration

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: red-csi-driver-block-sc-nginx-persistent
provisioner: block.csi.red.ddn.com
mountOptions:                        # list of options for `mount -o ...` command
#  - noatime                         #
```

#### _PersistentVolume_ configuration

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: red-csi-driver-block-pv-nginx-persistent
  labels:
    name: red-csi-driver-block-pv-nginx-persistent
spec:
  storageClassName: red-csi-driver-block-sc-nginx-persistent
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 1Gi
  csi:
    driver: block.csi.red.ddn.com
    volumeHandle: clu1/red/csiAccount:red/csiService/volumeName
    # parameters map
    volumeAttributes:
      #instances: '1,2,3'
  #mountOptions:  # list of options for `mount` command
  #  - noatime    #
```

CSI Parameters:

| Name           | Description                                                       | Example                              |
|----------------|-------------------------------------------------------------------|--------------------------------------|
| `driver`       | installed RED CSI block driver name "block.csi.red.ddn.com"        | `block.csi.red.ddn.com` |
| `volumeHandle` | CSI VolumeID [cluster/tenant/serviceAccountName:subtenant/serviceName/volumeName] | `clu1/red/csiAccount:red/csiService/vol1`               |
| `volumeAttributes` | CSI driver parametrs map [Defaults and params](#Defaults/Configuration/Parameter-options)   |  |

#### _PersistentVolumeClaim_ (pointed to created _PersistentVolume_)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: red-csi-driver-block-pvc-nginx-persistent
spec:
  storageClassName: red-csi-driver-block-sc-nginx-persistent
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  selector:
    matchLabels:
      # to create 1-1 relationship for pod - persistent volume use unique labels
      name: red-csi-driver-block-sc-nginx-persistent
```

#### Example

Run nginx server using PersistentVolume.

**Note:** Those RED objects MUST exist before static volume usage:
service account: `cluster/tenant/serviceAccount`. 
service : `cluster/tenant/subtenant/serviceName`.
volume : `cluster/tenant/subtenant/dataset/volume`.

```bash
kubectl apply -f examples/kubernetes/nginx-persistent-volume.yaml

# to delete this pod:
kubectl delete -f examples/kubernetes/nginx-persistent-volume.yaml
```

<!--
### Cloned volumes

We can create a clone of an existing csi volume.
To do so, we need to create a _PersistentVolumeClaim_ with _dataSource_ spec pointing to an existing PVC that we want to clone.
In this case Kubernetes generates volume name automatically (for example `pvc-red-cfc67950-fe3c-11e8-a3ca-005056b857f8`).

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: red-csi-driver-block-pvc-nginx-dynamic-clone
spec:
  storageClassName: red-csi-driver-block-sc-nginx-dynamic
  dataSource:
    kind: PersistentVolumeClaim
    apiGroup: ""
    name: red-csi-driver-block-sc-nginx-dynamic # pvc name
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```


#### Example

Run Nginx pod with dynamically provisioned volume:

```bash
kubectl apply -f examples/kubernetes/nginx-clone-volume.yaml

# to delete this pod:
kubectl delete -f examples/kubernetes/nginx-clone-volume.yaml
```
-->

## Uninstall

Using the same files as for installation:

```bash
# delete driver
kubectl delete -f deploy/kubernetes/red-csi-driver-block.yaml

# delete secret
kubectl delete secret red-csi-driver-block-config
```

## Troubleshooting

- Show installed drivers:
  ```bash
  kubectl get csidrivers
  kubectl describe csidrivers
  ```
- Error:
  ```
  MountVolume.MountDevice failed for volume "pvc-ns-<...>" :
  driver name block.csi.red.ddn.com not found in the list of registered CSI drivers
  ```
  Make sure _kubelet_ configured with `--root-dir=/var/lib/kubelet`, otherwise update paths in the driver yaml file
  ([all requirements](https://github.com/kubernetes-csi/docs/blob/387dce893e59c1fcf3f4192cbea254440b6f0f07/book/src/Setup.md#enabling-features)).
- "VolumeSnapshotDataSource" feature gate is disabled:
  ```bash
  vim /var/lib/kubelet/config.yaml
  # ```
  # featureGates:
  #   VolumeSnapshotDataSource: true
  # ```
  vim /etc/kubernetes/manifests/kube-apiserver.yaml
  # ```
  #     - --feature-gates=VolumeSnapshotDataSource=true
  # ```
  ```
- Driver logs
  ```bash
  kubectl logs --all-containers $(kubectl get pods | grep red-block-csi-controller | awk '{print $1}') -f
  kubectl logs --all-containers $(kubectl get pods | grep red-block-csi-node | awk '{print $1}') -f
  ```
- Show termination message in case driver failed to run:
  ```bash
  kubectl get pod red-csi-block-controller-0 -o go-template="{{range .status.containerStatuses}}{{.lastState.terminated.message}}{{end}}"
  ```
- Configure Docker to trust insecure registries:
  ```bash
  # add `{"insecure-registries":["10.3.199.92:5000"]}` to:
  vim /etc/docker/daemon.json
  service docker restart
  ```

