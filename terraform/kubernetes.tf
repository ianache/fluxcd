resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

data "kubernetes_config_map" "cacert" {
  metadata {
    name      = "kube-root-ca.crt"
    namespace = "kube-system"
  }
}

resource "vault_kubernetes_auth_backend_config" "config" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"
#  kubernetes_ca_cert     = data.kubernetes_config_map.cacert.data["ca.crt"]
#  token_reviewer_jwt     = "ZXhhbXBsZQo="
#  issuer                 = "api"
#  disable_iss_validation = "true"
}

