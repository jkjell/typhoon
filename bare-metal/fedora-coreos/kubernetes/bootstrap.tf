# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=d233e90754e68d258a60abf1087e11377bdc1e4b"

  cluster_name                    = var.cluster_name
  api_servers                     = [var.k8s_domain_name]
  etcd_servers                    = var.controllers.*.domain
  networking                      = var.install_container_networking ? var.networking : "none"
  network_mtu                     = var.network_mtu
  network_ip_autodetection_method = var.network_ip_autodetection_method
  pod_cidr                        = var.pod_cidr
  service_cidr                    = var.service_cidr
  cluster_domain_suffix           = var.cluster_domain_suffix
  enable_reporting                = var.enable_reporting
  enable_aggregation              = var.enable_aggregation
}


