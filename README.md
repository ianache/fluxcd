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
ENTORNO=dev
flux bootstrap github \
  --token-auth \
  --owner=ianache \
  --repository=fluxcd \
  --branch=master \
  --path=clusters/$ENTORNO \
  --personal
```

```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh
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

# Logs

```sh
kubectl -n flux-system logs -l 'app=helm-controller'
```

```sh
kubectl -n flux-system logs -l 'app=source-controller'
```

# MinIO

```yaml
console:
  ingress:
    enabled: true
    ingressClassName: "nginx"
    labels: {}
    annotations:
      company: xnetcorp
      cert-manager.io/cluster-issuer: selfsigned
    tls:
      - secretName: consul-tls
        hosts:
          - miniocp.crossnetcorp.com
    host: miniocp.crossnetcorp.com
    path: /
    pathType: Prefix
```

```sh
cat clusters/dev/infra/minio/release.yaml | yq .spec.values > /tmp/minio-operator.yaml
helm upgrade --install minio-operator minio/operator -n minio-operators --create-namespace --values /tmp/minio-operator.yaml
```

Para acceder con Token de Administrador

```sh
kubectl -n minio-operators  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode
```

```sh
cat clusters/dev/infra/minio/tenant-release.yaml | yq .spec.values > /tmp/minio-tenant.yaml
helm upgrade -i minio-tenant-1 minio/tenant -n minio-tenants --create-namespace --values /tmp/minio-tenant.yaml
```
