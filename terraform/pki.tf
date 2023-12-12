resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  description               = "Self signed Vault root CA"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 20 * 365 * 24 * 60 * 60 #87600
}

resource "vault_pki_secret_backend_root_cert" "root" {
  backend            = vault_mount.pki.path
  type               = "internal"
  common_name        = "crossnetcorp.com"
  issuer_name        = "root"
  #ttl                = "87600"

  ttl                = "630720000"
  format             = "pem"
  private_key_format = "der"
  key_type           = "rsa"
  key_bits           = 4096
}

resource "vault_pki_secret_backend_issuer" "root" {
   backend                        = vault_mount.pki.path
   issuer_ref                     = vault_pki_secret_backend_root_cert.root.issuer_id
   issuer_name                    = vault_pki_secret_backend_root_cert.root.issuer_name
   revocation_signature_algorithm = "SHA256WithRSA"
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = "servers"
  ttl              = 3600
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["crossnetcorp.com"]
  allow_subdomains = true
  allow_any_name   = true
}

resource "vault_pki_secret_backend_config_urls" "urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = [ "https://vault.crossnetcorp.com/v1/${vault_mount.pki.path}/ca" ]
  crl_distribution_points = [ "https://vault.crossnetcorp.com/v1/${vault_mount.pki.path}/crl" ]
}

#
# Intermediate PKI
#

resource "vault_mount" "pki_int" {
   path        = "pki_int"
   type        = "pki"
   description = "This is an intermediate PKI mount"

   default_lease_ttl_seconds = 86400
   max_lease_ttl_seconds     = 157680000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "csr-request" {
   backend            = vault_mount.pki_int.path
   type               = "internal"
   common_name        = "crossnetcorp.com"
   alt_names          = [ "crossnetcorp.com" ]
   format             = "pem"
   private_key_format = "der"
   key_type           = "rsa"
   key_bits           = 2048
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
   backend     = vault_mount.pki.path
   common_name = vault_pki_secret_backend_intermediate_cert_request.csr-request.common_name
   csr         = vault_pki_secret_backend_intermediate_cert_request.csr-request.csr
   use_csr_values = true
   ttl         = vault_mount.pki_int.max_lease_ttl_seconds
   #format      = "pem_bundle"
   #ttl         = 15480000
   #issuer_ref  = vault_pki_secret_backend_root_cert.root.issuer_id
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
   backend     = vault_mount.pki_int.path
   certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_config_urls" "int_urls" {
  backend                 = vault_mount.pki_int.path
  issuing_certificates    = [ "https://vault.crossnetcorp.com/v1/${vault_mount.pki_int.path}/ca" ]
  crl_distribution_points = [ "https://vault.crossnetcorp.com/v1/${vault_mount.pki_int.path}/crl" ]
}


#resource "vault_pki_secret_backend_issuer" "intermediate" {
#  backend     = vault_pki_secret_backend_root_cert.root.backend
#  issuer_ref  = vault_pki_secret_backend_root_cert.root.issuer_id
#  issuer_name = "example-issuer"
#}

resource "vault_pki_secret_backend_role" "intermediate_role" {
   backend          = vault_mount.pki_int.path
#   issuer_ref       = vault_pki_secret_backend_issuer.root.issuer_ref
   name             = "application"
   ttl              = 35.5 * 24 * 3600 #86400
   max_ttl          = 36 * 24 * 3600   # 2592000

   generate_lease     = false
   allow_bare_domains = true
   allow_glob_domains = true
   allow_ip_sans      = true
   allow_localhost    = true

   #allow_subdomains   = false
   #allowed_domains = [ "*.crossnetcorp.com" ]

   key_type         = "rsa"
   key_bits         = 4096
   allowed_domains  = ["crossnetcorp.com"]
   allow_subdomains = true

   key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
}
