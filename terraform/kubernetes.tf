resource "kubernetes_secret_v1" "issuer" {
  metadata {
    name = "issuer"
    annotations = {
      "kubernetes.io/service-account.name" = "issuer"
    }
  }
  wait_for_service_account_token = true
  type = "kubernetes.io/service-account-token"
  depends_on = [kubernetes_service_account_v1.issuer]
}

resource "kubernetes_service_account_v1" "issuer" {
  metadata {
    name = "issuer"
    namespace = "default"
  }
#  #secret {
#  #  name = "${kubernetes_secret_v1.issuer.metadata.0.name}"
#  #}
#  depends_on = [kubernetes_secret_v1.issuer]
}

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
#  kubernetes_host        = "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"
  token_reviewer_jwt     = "$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
  kubernetes_host        = "https://$KUBERNETES_PORT_443_TCP_ADDR:443" 
  kubernetes_ca_cert     = "@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

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
  token_policies                   = ["root"] #["pki"]
  # audience                         = "vault"
}
