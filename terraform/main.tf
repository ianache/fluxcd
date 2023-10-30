terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.21.0"
    }
  }
}

provider "vault" {
  address         = "https://vault.crossnetcorp.com/"
  token           = "root"
  skip_tls_verify = true
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
#  config_context = "my-context"
}
