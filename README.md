[[_TOC_]]

# Instalar Ansible

```sh
python3 -m pip -V
python3 -m pip install --user ansible
```

# Instalar Kind

```sh
ansible-playbook 01-install-kind.yaml
```

## Crear Cluster

```sh
ansible-playbook 02-create-cluster.yaml
```

Referencias:

1. https://fluxcd.io/flux/installation/bootstrap/github/

```sh
curl -s https://fluxcd.io/install.sh | sudo bash
```

Personal Access Token:

github_pat_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

```sh
flux bootstrap github \
  --token-auth \
  --owner=ianache \
  --repository=fluxcd \
  --branch=master \
  --path=clusters/kind8 \
  --personal
```


```sh
helm repo add fluxcd https://charts.fluxcd.io
```

```sh
kubectl create ns flux
```

```sh
kubectl create secret generic flux-git-deploy \
  --from-file=identity=/home/vagrant/.ssh/id_github \
  -n flux --dry-run=client \
  -o yaml | kubectl apply -f -
```

```sh
helm upgrade --install fluxcd fluxcd/helm-operator \
  --namespace operators \
  --create-namespace
```


# Destruir entorno

```sh
kind delete cluster --name comsatel-dev
```

