resource "vault_policy" "pki_policy" {
  name   = "pki"
  policy = file(format("%s/policies/pki-policy.hcl", path.module))
}
