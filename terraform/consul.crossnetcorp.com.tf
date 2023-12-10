resource "vault_pki_secret_backend_cert" "consul-crossnetcorp-com" {
  issuer_ref  = vault_pki_secret_backend_issuer.root.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "demo.crossnetcorp.com"
  ttl         = 3600
  revoke     = true
}
