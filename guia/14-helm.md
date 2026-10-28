# Guia direto 14 — Helm

> Perfil: `developer`. Projeto de treino: `ac14-helm`. **REQUER PREPARAÇÃO:** cliente `helm`
> ([docs/11-preparacao-helm.md](../docs/11-preparacao-helm.md)). Copie o chart antes de editar:
> `mkdir -p /tmp/ac14 && cp -r manifests/helm/ac14-loja /tmp/ac14/`. Exercícios completos: [trilhas/14-helm](../trilhas/14-helm/README.md).

## 1. Conferir a identidade — Leitura

```bash
source scripts/perfis.sh && ac-dev
oc whoami                       # developer
helm version --short
```

O Helm usa o mesmo `KUBECONFIG` do `oc`. Num terminal sem `ac-dev`, ele agiria como `system:admin`.

## 2. Ler e validar o chart — Leitura

```bash
helm show chart /tmp/ac14/ac14-loja
helm show values /tmp/ac14/ac14-loja
helm lint /tmp/ac14/ac14-loja
```

| Arquivo | Papel |
|---|---|
| `Chart.yaml` | nome, `version` (chart), `appVersion` (aplicação) |
| `values.yaml` | valores padrão |
| `values.schema.json` | validação (ex.: no máximo 2 réplicas) |
| `templates/` | modelos `{{ .Values.x }}`; `_helpers.tpl` com nome e rótulos |
| `templates/tests/` | pod usado por `helm test` |

## 3. Renderizar sem instalar — Leitura

```bash
helm template loja /tmp/ac14/ac14-loja -n ac14-helm
helm template loja /tmp/ac14/ac14-loja -f /tmp/ac14/ac14-loja/values-prod.yaml --show-only templates/deployment.yaml
helm template loja /tmp/ac14/ac14-loja --set replicaCount=2 --set route.enabled=false | oc apply --dry-run=server -n ac14-helm -f -
```

## 4. Instalar e ler a release — Altera

```bash
oc new-project ac14-helm
helm install loja /tmp/ac14/ac14-loja -n ac14-helm
helm list -n ac14-helm
helm status loja -n ac14-helm
helm get values loja -n ac14-helm --all
helm get manifest loja -n ac14-helm | grep '^kind:'
oc get secrets -n ac14-helm -l owner=helm          # o estado da release
```

## 5. Atualizar e a ordem dos valores — Altera

```bash
helm upgrade loja /tmp/ac14/ac14-loja -n ac14-helm -f /tmp/ac14/ac14-loja/values-prod.yaml
helm upgrade loja /tmp/ac14/ac14-loja -n ac14-helm -f /tmp/ac14/ac14-loja/values-prod.yaml --set pagina.conteudo='nova'
```

| Ordem (o último vence) | |
|---|---|
| 1 | `values.yaml` do chart |
| 2 | arquivos `-f`, na ordem |
| 3 | `--set`, na ordem |

`upgrade` sem `-f` **descarta** os valores passados antes. `--reuse-values` os mantém, mas ignora padrões novos do
chart ([TS-045](../cenarios/troubleshooting/TS-045.md)).

## 6. Histórico e rollback — Altera

```bash
helm history loja -n ac14-helm
helm rollback loja 1 -n ac14-helm          # cria uma revisão nova "Rollback to 1"
```

## 7. Upgrade seguro — Altera

```bash
helm upgrade loja /tmp/ac14/ac14-loja -n ac14-helm --set image.tag=nao-existe --atomic --timeout 60s
helm history loja -n ac14-helm | tail -3   # failed + rollback automático
```

| Opção | Efeito |
|---|---|
| (nenhuma) | marca `deployed` sem esperar os pods |
| `--wait --timeout` | espera os pods; `failed` se não ficarem prontos |
| `--atomic` | `--wait` + rollback automático |

## 8. Testar a release — Altera

```bash
helm test loja -n ac14-helm
helm get manifest loja -n ac14-helm | oc diff -n ac14-helm -f -    # alguém mudou algo "por fora"?
```

## 9. Modelos — Leitura

| Construção | Uso |
|---|---|
| `{{- if .Values.x }} ... {{- end }}` | bloco opcional |
| `{{- with .Values.x }} {{ . }} {{- end }}` | opcional, mudando o contexto |
| `{{- range $k, $v := .Values.mapa }}` | repetir |
| `{{ .Values.x \| default "y" }}` / `{{ required "msg" .Values.x }}` | padrão / obrigatório |
| `{{ toYaml .Values.obj \| nindent 8 }}` | bloco YAML indentado |

Depure com `helm template ... --debug`.

## 10. Charts de terceiros: auditar antes — Leitura

```bash
helm repo add openshift-helm-charts https://charts.openshift.io/ && helm repo update
helm search repo openshift-helm-charts | head
helm pull <repo/chart> --untar -d /tmp/ac14/terceiros
helm template x /tmp/ac14/terceiros/* | grep '^kind:' | sort | uniq -c
```

Não instale na Academia charts que criem `ClusterRole`, CRDs, SCC ou que passem da quota.

## 11. Diagnóstico — Leitura

| Mensagem | Causa | Onde |
|---|---|---|
| `another operation ... is in progress` | revisão presa em `pending-*` | [TS-043](../cenarios/troubleshooting/TS-043.md) |
| `invalid ownership metadata` | objeto criado fora do Helm | [TS-044](../cenarios/troubleshooting/TS-044.md) |
| padrão novo não chegou | `--reuse-values` | [TS-045](../cenarios/troubleshooting/TS-045.md) |
| `cannot re-use a name` | release já existe | use `upgrade` |
| `values don't meet the specifications of the schema` | valor inválido | HLM-008 |
| `context deadline exceeded` | pods não ficaram prontos | eventos, `helm rollback` |

## 12. Encerrar a trilha — Altera

```bash
helm uninstall loja -n ac14-helm
helm uninstall vitrine -n ac14-helm 2>/dev/null || true
oc delete project ac14-helm
rm -rf /tmp/ac14
helm repo remove openshift-helm-charts 2>/dev/null || true
```
