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

resource "vault_kubernetes_auth_backend_role" "role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "issuer"
  bound_service_account_names      = ["issuer"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = ["pki"]
  # audience                         = "vault"
}
