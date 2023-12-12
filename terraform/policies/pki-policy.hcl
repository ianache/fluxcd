path "pki*" {
  capabilities = ["read", "list"]
}

path "pki/roles/crossnetcorp-com" {
  capabilities = ["create", "update"]
}

path "pki/sign/crossnetcorp-com"{
  capabilities = ["create", "update"]
}

path "pki/issue/crossnetcorp-com" {
  capabilities = ["create"]
}

