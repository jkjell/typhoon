# Security

Typhoon aims to be minimal and secure. We're running it ourselves after all.

## Overview

**Kubernetes**

* etcd with peer-to-peer and client-auth TLS
* Kubelets TLS bootstrap certificates (72 hours)
* Generated TLS certificate (365 days) for admin `kubeconfig`
* [NodeRestriction](https://kubernetes.io/docs/reference/access-authn-authz/node/) is enabled to limit Kubelet authorization
* [Role-Based Access Control](https://kubernetes.io/docs/admin/authorization/rbac/) is enabled. Apps must define RBAC policies for API access
* Workloads run on worker nodes only, unless they tolerate the master taint
* Kubernetes [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) and Cilium [NetworkPolicy](https://docs.cilium.io/en/latest/security/policy/index.html) support [^1]

[^1]: Requires `networking = "cilium"`. Cilium is the default on all platforms (AWS, Azure, bare-metal, DigitalOcean, and Google Cloud).

**Hosts**

* Container Linux auto-updates are enabled
* Hosts limit logins to SSH key-based auth (user "core")
* SELinux enforcing mode [^2]

[^2]: SELinux is enforcing on Fedora CoreOS, permissive on Flatcar Linux.

**Platform**

* Cloud firewalls limit access to ssh, kube-apiserver, and ingress
* No cluster credentials are stored in Matchbox (used for bare-metal)
* No cluster credentials are stored in Digital Ocean metadata
* Cluster credentials are stored in AWS metadata (for ASGs)
* Cluster credentials are stored in Azure metadata (for scale sets)
* Cluster credentials are stored in Google Cloud metadata (for managed instance groups)
* No account credentials are available to Digital Ocean droplets
* No account credentials are available to AWS EC2 instances (no IAM permissions)
* No account credentials are available to Azure instances (no IAM permissions)
* No account credentials are available to Google Cloud instances (no IAM permissions)

## Precautions

Typhoon limits exposure to many security threats, but it is not a silver bullet. As usual,

* Do not run untrusted images or accept manifests from strangers
* Do not give untrusted users a shell behind your firewall
* Define network policies for your namespaces

## Container Images

Typhoon uses upstream container images (where possible) and upstream binaries.

!!! note
    Kubernetes releases `kubelet` as a binary for distros to package, either as a DEB/RPM on traditional distros or as a container image for container-optimized operating systems.

Typhoon [packages](https://github.com/poseidon/kubelet) the upstream Kubelet and its dependencies as a [container image](https://quay.io/repository/poseidon/kubelet). Builds fetch the upstream Kubelet binary and verify its checksum.

The Kubelet image is published to Quay.io and Dockerhub.

* [quay.io/poseidon/kubelet](https://quay.io/repository/poseidon/kubelet) (official)
* [docker.io/psdn/kubelet](https://hub.docker.com/r/psdn/kubelet) (fallback)

Two tag styles indicate the build strategy used.

* Typhoon internal infra publishes single and multi-arch images (e.g. `v1.18.4`, `v1.18.4-amd64`, `v1.18.4-arm64`, `v1.18.4-2-g23228e6-amd64`, `v1.18.4-2-g23228e6-arm64`)
* Quay automated builds publish verifiable images (e.g. `build-SHA` on Quay)

The Typhoon-built Kubelet image is used as the official image. Automated builds provide an alternative image for those preferring to trust images built by Quay (albeit lacking multi-arch). To use the fallback registry or an alternative tag, see [customization](/advanced/customization/#system-images).

### flannel-cni

Typhoon packages the [flannel-cni](https://github.com/poseidon/flannel-cni) container image to provide security patches.

* [quay.io/poseidon/flannel-cni](https://quay.io/repository/poseidon/flannel-cni) (official)

## Terraform Providers

Typhoon publishes Terraform providers to the Terraform Registry, GPG signed by 0x8F515AD1602065C8.

| Name     | Source | Registry |
|----------|--------|----------|
| ct       | [github](https://github.com/poseidon/terraform-provider-ct) | [poseidon/ct](https://registry.terraform.io/providers/poseidon/ct/latest) |
| matchbox | [github](https://github.com/poseidon/terraform-provider-matchbox) | [poseidon/matchbox](https://registry.terraform.io/providers/poseidon/matchbox/latest) |

## kube-system

| Name           | user   | hostNet | privileged |
|----------------|--------|---------|------------|
| kube-apiserver | nobody | true    | false      |
| kube-controller-manager | nobody | true | false |
| kube-scheduler | nobody | true    | false      |
| coredns        | NA     | false   | false      |
| kube-proxy     | root   | true    | true       |
| cilium         | root   | true    | true       |
| flannel        | root   | true    | true       |


| Name                    | priorityClassName |
|-------------------------|-------------------|
| kube-apiserver          | system-cluster-critical |
| kube-controller-manager | system-cluster-critical |
| kube-scheduler          | system-cluster-critical |
| coredns                 | system-cluster-critical |
| kube-proxy              | system-node-critical |
| cilium                  | system-node-critical |
| flannel                 | system-node-critical |

## Disclosures

If you find security issues, please email `security@psdn.io`. If the issue lies in upstream Kubernetes, please inform upstream Kubernetes as well.

