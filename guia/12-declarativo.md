# Guia direto 12 — Manifestos declarativos

> Perfil: `developer`. Projeto de treino: `ac12-declarativo`. Arquivo de trabalho: `/tmp/ac12/app.yaml` (cópia de
> `manifests/apps-exemplo/declarativo-app.yaml`). Exercícios completos: [trilhas/12-declarativo](../trilhas/12-declarativo/README.md).

## 1. Gerar manifestos — Leitura

```bash
oc new-project ac12-declarativo
mkdir -p /tmp/ac12
oc create deployment ac12-web --image=registry.access.redhat.com/ubi9/httpd-24:latest --port=8080 --dry-run=client -o yaml > /tmp/ac12/deploy.yaml
oc create service clusterip ac12-web --tcp=8080:8080 --dry-run=client -o yaml > /tmp/ac12/svc.yaml
oc create configmap ac12-pagina --from-literal=index.html='versao 1' --dry-run=client -o yaml > /tmp/ac12/cm.yaml
```

`--dry-run=client -o yaml` imprime o objeto em vez de criá-lo. Remova `status: {}` e `creationTimestamp: null`;
junte vários objetos em um arquivo separando-os com `---`.

## 2. Validar — Leitura

```bash
cp manifests/apps-exemplo/declarativo-app.yaml /tmp/ac12/app.yaml
oc apply --dry-run=client -f /tmp/ac12/app.yaml -n ac12-declarativo
oc apply --dry-run=server --validate=strict -f /tmp/ac12/app.yaml -n ac12-declarativo
```

| Validação | Pega |
|---|---|
| `--dry-run=client` | YAML inválido |
| `--dry-run=server` | esquema, defaults, quota, LimitRange, SCC |
| `--validate=strict` | campo desconhecido vira erro (`replicaz`) |

## 3. Aplicar e reaplicar — Altera

```bash
oc apply -f /tmp/ac12/app.yaml -n ac12-declarativo        # cria
oc apply -f /tmp/ac12/app.yaml -n ac12-declarativo        # unchanged
oc create -f /tmp/ac12/app.yaml -n ac12-declarativo       # AlreadyExists
oc apply view-last-applied deployment/ac12-web -n ac12-declarativo
```

| | `create -f` | `apply -f` |
|---|---|---|
| não existe | cria | cria |
| existe | erro | mescla as diferenças |
| repetível | não | sim |

## 4. Diff antes de tudo — Leitura

```bash
sed -i 's/versao 1/versao 2/' /tmp/ac12/app.yaml
oc diff -f /tmp/ac12/app.yaml -n ac12-declarativo; echo "rc=$?"
oc apply -f /tmp/ac12/app.yaml -n ac12-declarativo
```

Código de saída: `0` nada muda, `1` há mudanças, `>1` erro.

## 5. O que o apply preserva e o que apaga — Altera

| Situação | Resultado do `apply` |
|---|---|
| campo saiu do arquivo (estava no last-applied) | **removido** |
| campo declarado com valor diferente do vivo | **sobrescrito** pelo arquivo |
| campo nunca declarado, alterado por outro | **preservado** |

```bash
oc scale deployment/ac12-web --replicas=2 -n ac12-declarativo
oc apply -f /tmp/ac12/app.yaml -n ac12-declarativo        # volta a 1: replicas está no arquivo
```

Com HPA, **tire `replicas` do arquivo** ([TS-038](../cenarios/troubleshooting/TS-038.md)).

## 6. Server-side apply — Altera

```bash
oc apply --server-side --field-manager=equipe-a -f /tmp/ac12/app.yaml -n ac12-declarativo
oc get deployment ac12-web -n ac12-declarativo --show-managed-fields -o json | jq '.metadata.managedFields[].manager'
```

O servidor registra o dono de cada campo; outro gerenciador que tente mudá-lo recebe **conflito**. `--force-conflicts`
assume o campo — combine antes ([TS-039](../cenarios/troubleshooting/TS-039.md)).

## 7. Replace — Altera

```bash
oc replace -f /tmp/ac12/app.yaml -n ac12-declarativo
```

`replace` substitui o objeto inteiro: o que não está no arquivo some. `resourceVersion` no arquivo causa
`the object has been modified`. `--force` **apaga e recria** (todos os pods saem).

## 8. Os três tipos de patch — Altera

```bash
oc patch deployment ac12-web -n ac12-declarativo -p '{"spec":{"template":{"spec":{"containers":[{"name":"web","env":[{"name":"NIVEL","value":"1"}]}]}}}}'
oc patch deployment ac12-web -n ac12-declarativo --type=merge -p '{"metadata":{"annotations":{"dono":"academia"}}}'
oc patch deployment ac12-web -n ac12-declarativo --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/env/1/value","value":"2"}]'
```

| `--type` | Listas |
|---|---|
| `strategic` (padrão) | mescla por nome (`containers`, `env`) |
| `merge` | **substitui a lista inteira** (cuidado com `containers`) |
| `json` | operações por índice (`add`, `remove`, `replace`, `test`) |

Prévia sem gravar: acrescente `--dry-run=server -o yaml`.

## 9. Editar arquivos sem cluster — Leitura

```bash
oc label --local -f /tmp/ac12/deploy.yaml ambiente=prod -o yaml
oc set image --local -f /tmp/ac12/deploy.yaml httpd-24=registry.access.redhat.com/ubi8/httpd-24:latest -o yaml
oc patch --local -f /tmp/ac12/deploy.yaml --type=merge -p '{"spec":{"replicas":2}}' -o yaml
```

`--local` muda o arquivo e imprime o resultado; nada é enviado ao cluster.

## 10. Exportar um objeto vivo — Leitura

```bash
oc get deployment ac12-web -n ac12-declarativo -o json | jq 'del(.status, .metadata.uid, .metadata.resourceVersion,
  .metadata.generation, .metadata.creationTimestamp, .metadata.managedFields, .metadata.namespace)' > /tmp/ac12/export.json
```

Não vão para o manifesto: `status`, `uid`, `resourceVersion`, `managedFields`, anotações geradas, `clusterIP`.

## 11. Diretórios, prune e delete — Altera

```bash
oc apply -f /tmp/ac12/dir/ -n ac12-declarativo            # todos os arquivos, em ordem alfabética (-R entra em subpastas)
oc wait --for=condition=Available deployment/ac12-web -n ac12-declarativo --timeout=120s
oc apply -f /tmp/ac12/dir/ -n ac12-declarativo --prune -l app=ac12-web \
  --prune-allowlist=core/v1/ConfigMap --prune-allowlist=core/v1/Service \
  --prune-allowlist=apps/v1/Deployment --prune-allowlist=route.openshift.io/v1/Route --dry-run=server
oc delete -f /tmp/ac12/app.yaml -n ac12-declarativo --dry-run=client
```

Prune apaga o que saiu do diretório: **sempre** com `-n`, seletor específico, `--prune-allowlist` e dry-run antes.

## 12. Diagnóstico — Leitura

| Mensagem | Causa | Correção |
|---|---|---|
| `unknown field` | digitação | `oc explain` |
| `AlreadyExists` | `create` repetido | `apply` |
| `the object has been modified` | `resourceVersion` antigo | tirar do arquivo |
| `field is immutable` | seletor e afins | reverter ou criar ao lado ([TS-037](../cenarios/troubleshooting/TS-037.md)) |
| `Apply failed with N conflict(s)` | SSA, campo de outro | combinar ([TS-039](../cenarios/troubleshooting/TS-039.md)) |
| escala volta sozinha | `replicas` no arquivo | tirar do arquivo ([TS-038](../cenarios/troubleshooting/TS-038.md)) |

## 13. Encerrar a trilha — Altera

```bash
oc delete project ac12-declarativo
oc delete project ac12-rascunho --ignore-not-found
oc get project ac12-declarativo      # até NotFound
rm -rf /tmp/ac12
```
