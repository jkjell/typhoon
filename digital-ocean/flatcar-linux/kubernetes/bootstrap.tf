# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=209e02b4f26fd8d0580b0ecd07759e3ae76e7550"

  cluster_name = var.cluster_name
  api_servers  = [format("%s.%s", var.cluster_name, var.dns_zone)]
  etcd_servers = digitalocean_record.etcds.*.fqdn

  networking   = var.networking
  pod_cidr     = var.pod_cidr
  service_cidr = var.service_cidr
  components   = var.components
}

