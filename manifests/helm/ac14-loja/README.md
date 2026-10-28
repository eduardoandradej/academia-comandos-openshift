# Chart `ac14-loja` (Trilha 14)

Chart local de treino: httpd servindo uma página de ConfigMap, Service, Route opcional e um teste (`helm test`).

| Arquivo | Conteúdo |
|---|---|
| `Chart.yaml` | nome, versão do chart (`version`) e da aplicação (`appVersion`) |
| `values.yaml` | valores padrão |
| `values-prod.yaml` | valores de "produção" (2 réplicas, página e variável) |
| `values.schema.json` | validação: `replicaCount` inteiro entre 1 e 2, digest no formato certo |
| `templates/` | modelos Go; `_helpers.tpl` concentra nome, rótulos e imagem |
| `templates/tests/` | pod de teste executado por `helm test` |

```bash
helm lint manifests/helm/ac14-loja
helm template loja manifests/helm/ac14-loja -n ac14-helm
helm install loja manifests/helm/ac14-loja -n ac14-helm
```

Copie para `/tmp/ac14/ac14-loja` antes de editar. Os modelos não foram renderizados pelo autor (sem `helm` no ambiente
de escrita): rode `helm lint` primeiro e abra uma issue se algo falhar.
