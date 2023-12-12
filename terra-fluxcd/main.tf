terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
      version = "1.1.2"
    }
  }
}

provider "flux" {
  kubernetets = {
    config_path = "~/.kube/config"
  }
  git = {
    url = "https://github.com/ianache/fluxcd.git"
  }
}
