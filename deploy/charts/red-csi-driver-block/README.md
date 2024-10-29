# red-csi-driver-block

The red-csi-driver-block chart adds RED volume support to your cluster.

## Install chart

To install the Chart into your Kubernetes cluster

Run commands on top of `https://github.com/DDNStorage/red-csi-driver-block` repository

- Prepare RED cluster configuration in `./deploy/charts/red-csi-driver-block/values.yaml` file

  Specify RED Cluster API endpoint(s), user(s) and password(s) into config section of the file
  by the schema

  ```yaml
  config:                                                # Global configuration name (shouldn't be changed)
    realms:                                              # Global realms map name (shouldn't be changed)
      realmA:                                            # Name of the realm configuration entry (`realmA` is default value, could be changed)
        apis: https://<IP or FQDN>:443                   # [required] RED REST API endpoint(s)
        username: <RED API USERNAME>                     # [required] RED REST API username
        password: <RED API PASSWORD>                     # [required] RED REST API password
  ```
  [Defaults and configuration options](#defaults-and-configuration-options)

  **It will create secret based on configuration in the same namespace as specified during `helm install`**


- Run the installation

```bash
   helm install --create-namespace --namespace red-block-csi red-csi-driver-block ./deploy/charts/red-csi-driver-block
```

- After installation succeeds, you can get a status of Chart

```bash
helm status red-csi-driver-block
```

## Delete Chart

If you want to delete your Chart, use this command

```bash
   helm uninstall -n red-block-csi red-csi-driver-block
```

## Upgrade Chart

If you want to upgrade your Chart to different RED CSI driver release

- Change driver.tag value in ./deploy/charts/red-csi-driver-block/values.yaml file
- Apply command

```bash
helm upgrade --namespace red-block-csi red-csi-driver-block ./deploy/charts/red-csi-driver-block
```

## Defaults and configuration options

| Default  | Config               |   Desc                             |
|----------|----------------------|-----------------------------------|
|   -      |   apis               | List of RED API entrypoints       |
|   -      |   user               | RED API user                      |
|   -      |   password           | RED API user password             |
|   -      |   zone               | Zone to match topology.kubernetes.io/zone            |
|   -      |   insecureSkipVerify | TLS certificates check will be skipped when `true` (default: 'true')           |
|   "clu1" | default_cluster      | RED cluster name                  |
|   "red"  | default_tenant       | RED tenant name                   |
|   "red"  | default_subtenant    | RED subtenant name                |
|   "red"  | default_dataset      | RED dataset name                  |
|   []     | default_instance_ids | Red cluster instances ID for expose|
|   4420   | default_data_port    | BDEV expose port                  |
