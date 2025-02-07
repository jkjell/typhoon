# Kubernetes assets (kubeconfig, manifests)
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=c50071487ccd9a29f25767a5fa79dca260be7b86"

  cluster_name           = var.cluster_name
  api_servers            = [format("%s.%s", var.cluster_name, var.dns_zone)]
  service_account_issuer = var.service_account_issuer
  etcd_servers           = aws_route53_record.etcds.*.fqdn
  networking             = var.networking
  pod_cidr               = var.pod_cidr
  service_cidr           = var.service_cidr
  daemonset_tolerations  = var.daemonset_tolerations
  components             = var.components
}

