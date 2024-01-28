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

# Acceso a Dashboard Kubernetes

```sh
kubectl -n management create token dashboard-admin-user
```

Por ejemplo,

```sh
eyJhbGciOiJSUzI1NiIsImtpZCI6ImF4WjlEQzZFVnd5R3VjM0l5NWhCZ3Z6OW1DNzNJWl8xOVZtdjlKdWFPaEEifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzA1OTAxNDczLCJpYXQiOjE3MDU4OTc4NzMsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJtYW5hZ2VtZW50Iiwic2VydmljZWFjY291bnQiOnsibmFtZSI6ImRhc2hib2FyZC1hZG1pbi11c2VyIiwidWlkIjoiNWI2MGYwNTEtYzFmMy00YjQxLWEzZmUtYjQ3ZGNmZGJhOGIzIn19LCJuYmYiOjE3MDU4OTc4NzMsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50OmRhc2hib2FyZC1hZG1pbi11c2VyIn0.qY-zM5wlp57V_rW1pruxERe7mwFxjokgU-tBwvdYwz2-3YN8rAgsRY2VKNMQWtlgi-VC0L7hscL3Zx0icZtImxBxUsCxV1ivHvWAb-MRqPp6qpsoCrPWrS1M8axLUtxIo0aUcWkpzD5EfUvZ7nkPf9w4rcRKGctV8Hc6-Xw3y8CxEHirDdK2Bg-6ZXzuRSix2smOiYWZ59stYKmyH21axXcqEiDR0wpBRE9qZxVdmVEP9r1Z6nH4gzYWJYVUbeEshK-Y0zsTFM2VunkKa8gFENdkkmU_jzJq-ZbqLoDsgS5VqYlh9hxIenzkWgOw0len8CcuRU8C9VUAYP-ORgJVIA
```

# Generar clave aleatoria

```sh
PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
echo "The password for user@example.com is  $PASSWD"
KF_PASSWD=$(htpasswd -nbBC 12 USER $PASSWD| sed -r 's/^.{5}//')
echo "Password: $KF_PASSWD"
```
