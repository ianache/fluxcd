resource "vault_policy" "pki_policy" {
  name   = "pki"
  policy = file("policies/pki-policy.hcl")
}
