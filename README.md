# Instalar Kind

```sh
ansible-playbook 01-install-kind.yaml
```

## Crear Cluster

```sh
ansible-playbook 02-create-cluster.yaml
```

# Destruir entorno

```sh
kind delete cluster --name comsatel-dev
```

