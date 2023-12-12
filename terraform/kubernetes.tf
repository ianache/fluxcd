#resource "kubernetes_secret_v1" "issuer" {
#  metadata {
#    name = "issuer"
#    annotations = {
#      "kubernetes.io/service-account.name" = "issuer"
#    }
#  }
#  wait_for_service_account_token = true
#  type = "kubernetes.io/service-account-token"
#  depends_on = [kubernetes_service_account_v1.issuer]
#}
#
#resource "kubernetes_service_account_v1" "issuer" {
#  metadata {
#    name = "issuer"
#    namespace = "default"
#  }
##  #secret {
##  #  name = "${kubernetes_secret_v1.issuer.metadata.0.name}"
##  #}
##  depends_on = [kubernetes_secret_v1.issuer]
#}

# (1) Habilitar servicio de autenticacion con Kubernetes
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
  description = "k8s authentication backend mount"
}

# (2) Obtener el certificado de k8s
data "kubernetes_config_map" "cacert" {
  metadata {
    name      = "kube-root-ca.crt"
    namespace = "kube-system"
  }
}

# (3) 
resource "vault_kubernetes_auth_backend_config" "config" {
  backend          = vault_auth_backend.kubernetes.path
  kubernetes_host  = "https://kubernetes.default.svc"
  kubernetes_ca_cert = data.kubernetes_config_map.cacert.data["ca.crt"]
  #kubernetes_ca_cert = base64decode(data.kubernetes_config_map.cacert.data["ca.crt"])


#  kubernetes_host        = "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"
#  token_reviewer_jwt     = "$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
#  kubernetes_host        = "https://$KUBERNETES_PORT_443_TCP_ADDR:443" 
#  kubernetes_ca_cert     = "@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

#  kubernetes_ca_cert     = data.kubernetes_config_map.cacert.data["ca.crt"]
#  token_reviewer_jwt     = "ZXhhbXBsZQo="
#  issuer                 = "api"
#  disable_iss_validation = "true"
}

resource "vault_kubernetes_auth_backend_role" "role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "issuer"
  bound_service_account_names      = [ "cert-manager" ] #[ "issuer" ]
  bound_service_account_namespaces = [ "default" ] #[ "default" ]
  token_ttl                        = 3600
  token_policies                   = [
    "pki",
    "root",
  ]
  # audience                         = "vault"
}
