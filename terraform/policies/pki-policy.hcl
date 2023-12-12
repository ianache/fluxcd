path "auth/kubernetes/login" {
  capabilities = ["read"]
}

path "pki/issue/*" {
  capabilities = ["create", "read", "update"]
}

path "pki/certs" {
  capabilities = ["list"]
}

path "pki/cert/*" {
  capabilities = ["read"]
}

path "pki/sign/*" {
  capabilities = ["create", "read", "update"]
}

path "pki/ca/*" {
  capabilities = ["read"]
}

path "pki/ca_chain" {
  capabilities = ["read"]
}

path "pki/crl/*" {
  capabilities = ["read", "list"]
}

#path "pki*" {
#  capabilities = ["read", "list"]
#}
#
#path "pki/roles/crossnetcorp-com" {
#  capabilities = ["create", "update"]
#}
#
#path "pki/sign/crossnetcorp-com"{
#  capabilities = ["create", "update"]
#}
#
#path "pki/issue/crossnetcorp-com" {
#  capabilities = ["create"]
#}

