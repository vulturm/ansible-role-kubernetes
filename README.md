[//]: # (Describe the project's purpose.)

## `ansible-role-kubernetes` - ansible role

The `ansible-role-kubernetes` project goal is to automate the installation of a `kubernetes cluster`.

This will be used as a component playbook during our cluster bringup/configure.

[//]: # (Describe the technology used.)

## What is ansible
[Ansible][1] is open source software that automates software provisioning, configuration management, and application deployment.
Simple yaml based configuration that gives you a single view of your entire infrastructure.

[//]: # (List Project dependencies.)

## Dependencies
| Dependency | Description | Comments |
|:---------|:----------|:----------|
| `ansible` | This project was developed and tested using `Ansible v2.9.3`. | Ansible needs to be installed on the control host. |
| `docker` | This project was developed and tested using `Docker version 19.03.8`. | Docker needs to be installed on the kubernetes hosts. |


## Deployment hardware requirements
| Dependency type | Comments |
|:---------|:----------|
| `hardware` | `The setup` is expecting at least a master system(3 preferably) with 4G of RAM. Nodes with at least 8G of RAM.|
| `software` | `Infrastructure Provisioning Scripts` were developed with CentOS 7.6, 64 bit in mind. `Kubernetes` installation was tested on a CentOS host system, also. |


## Inventory files
|   Name               | Description                                                      |
|----------------------|------------------------------------------------------------------|
| `inventory/[component]_[environment].yml` | Inventory files are stored in the `inventory/` folder. The naming convention contains `[component]_[environment].yml` |
---


## Role configuration
* Available variables are listed below (also, see `defaults/main.yml`).

[//]: # (Segment attributes by category.)

[//]: # (### Top Level Variables)
[//]: # (|Variable |Type |Description |Comments |)
[//]: # (|:---------|:----|:-----------|:--------|)
[//]: # (| | | | |)


|Variable |Type |Description |Comments |
|:---------|:----|:-----------|:--------|
| `kubernetes_version` | *String* | The minor version of Kubernetes to install. | The plain `kubernetes_version` is used to pin an apt package version on Debian, and as the Kubernetes version passed into the `kubeadm init` command (see `kubernetes_version_kubeadm`). |
| `kubernetes_packages` | *Map* | Optional. By default, it has all the required `Kubernetes packages` to be installed on the server. | You can either provide a list of package names, or set `name` and `state` to have more control over whether the package is `present`, `absent`, `latest`, etc. |
| `kubernetes_version_rhel_package` | *String* | The `kubernetes_version_rhel_package` variable must be a specific Kubernetes release, and is used to pin the version on Red Hat / CentOS servers.
| `kubernetes_kubelet_extra_args` | *String* | Extra args to pass to `kubelet` during startup. E.g. to allow `kubelet` to start up even if there is swap is enabled on your server, set this to: `"--fail-swap-on=false"`. | Or to specify the node-ip advertised by `kubelet`, set this to `"--node-ip={{ ansible_host }}"`. |
| `kubernetes_kubeadm_init_extra_opts` | *String* | Extra options to pass to `kubeadm init` during K8s control plane initialization. | E.g. to specify extra Subject Alternative Names for API server certificate, set this to: `"--apiserver-cert-extra-sans my-custom.host"`. |
| `kubernetes_join_command_extra_opts` | *String* | Extra options to pass to the generated `kubeadm join` command during K8s node join. | E.g. to ignore certain preflight errors like swap being enabled, set this to: `--ignore-preflight-errors=Swap`. |
| `kubernetes_allow_pods_on_master` | *Boolean* | Whether to remove the taint that denies pods from being deployed to the Kubernetes master. | If you have a single-node cluster, this should definitely be `True`. Otherwise, set to `False` if you want a dedicated Kubernetes master which doesn't run any other pods. |
| `kubernetes_apiserver_advertise_address` | *String* | The IP address the API Server will advertise it's listening on. | If not set the default network interface will be used: `ansible_default_ipv4.address` if it's left empty. |
| `kubernetes_version_kubeadm` | *String* | Optional. Detected from `kubernetes_version`. | This will be passed in as `--kubernetes-version` when pulling kubernetes components. |
| `kubernetes_ignore_preflight_errors` | *String* | Optional. Defaults to 'all'. Value 'all' ignores errors from all checks. | This is a list of checks whose errors will be shown as warnings. Example: 'IsPrivilegedUser,Swap'. |
| `kubernetes_apply_yml_manifests` | *List* | Optional. A list of yaml manifests that are to be executed on the cluster. | This is handy because it can be used to install networking and customize k8s during installation. |

---


## Networking options

    # Flannel CNI.
    # cidr: '10.244.0.0/16'
    # https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    #
    # Calico CNI.
    # cidr: '192.168.0.0/16'
    # https://docs.projectcalico.org/v3.11/manifests/calico.yaml
    #
    # WeaveNet CNI
    # cidr: '10.32.0.0/12'
    # https://cloud.weave.works/k8s/net?k8s-version={{ kubernetes_version }}

    kubernetes_pod_network:
      # make sure you choose the appropriate subnet
      cidr: '10.32.0.0/12'
      yaml_manifest: "https://cloud.weave.works/k8s/net?k8s-version={{ kubernetes_version }}"

---

## Usage

* Whether the particular server will serve as a Kubernetes `master` or `node` is influenced by the fact that the node is a part of the group `kube_master` or `kube_node`.
* The master will have `kubeadm init` run on it to intialize the entire K8s control plane, while `node`s will have `kubeadm join` run on them to join the cluster.


### Single node (master-only) cluster

```yaml
- hosts: all

  vars:
    kubernetes_allow_pods_on_master: true

  roles:
    - ansible-role-docker
    - ansible-role-kubernetes
```

### Two or more nodes cluster

* Master members, add them to: `kube_master` group.
* Node members, add them to `kube_node` group.

Playbook:

```yaml
- hosts: all

  roles:
    - ansible-role-docker
    - ansible-role-kubernetes
```

Then, log into the Kubernetes master, and run `kubectl get nodes` as root, and you should see a list of all the servers.


## Authors / Maintainers
This code is based on a role created in 2018 by [Jeff Geerling](https://www.jeffgeerling.com/).


* Current Maintainer - Mihai Vultur
* Team - SRE

[1]: http://www.ansible.com/ "Ansible"
