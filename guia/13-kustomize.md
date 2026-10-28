# Guia direto 13 — Kustomize e Templates

> Perfil: `developer`. Projetos: `ac13-kustomize`, `ac13-dev`, `ac13-prod`. Copie os exemplos antes de editar:
> `mkdir -p /tmp/ac13 && cp -r manifests/kustomize /tmp/ac13/`. Exercícios completos: [trilhas/13-kustomize](../trilhas/13-kustomize/README.md).

## 1. Renderizar sem aplicar — Leitura

```bash
cat /tmp/ac13/kustomize/base/kustomization.yaml
oc kustomize /tmp/ac13/kustomize/base
```

| Campo | O que faz |
|---|---|
| `resources` | arquivos incluídos |
| `labels` com `includeSelectors: false` | rótulo em todos os objetos e pods, sem mexer em seletores |
| `configMapGenerator` | cria o ConfigMap com **sufixo de hash** e corrige quem o referencia |

## 2. Aplicar, comparar, remover — Altera

```bash
oc new-project ac13-kustomize
oc apply -k /tmp/ac13/kustomize/base -n ac13-kustomize
oc diff -k /tmp/ac13/kustomize/base -n ac13-kustomize
oc delete -k /tmp/ac13/kustomize/base -n ac13-kustomize --dry-run=client
```

Mudou o `index.html`? O hash muda, o nome do ConfigMap muda, o Deployment faz **rollout sozinho**.

## 3. Overlays: um diretório por ambiente — Altera

```bash
oc new-project ac13-dev; oc new-project ac13-prod; oc project ac13-kustomize
diff <(oc kustomize /tmp/ac13/kustomize/overlays/dev) <(oc kustomize /tmp/ac13/kustomize/overlays/prod)
oc apply -k /tmp/ac13/kustomize/overlays/dev            # sem -n: o overlay define o namespace
oc apply -k /tmp/ac13/kustomize/overlays/prod
```

```yaml
# overlays/prod/kustomization.yaml (resumo)
resources: [../../base]
namespace: ac13-prod
replicas: [{name: ac13-loja, count: 2}]
images: [{name: registry.access.redhat.com/ubi9/httpd-24, newTag: latest}]   # troque por digest
configMapGenerator: [{name: ac13-pagina, behavior: replace, literals: ["index.html=loja da academia (prod)"]}]
patches: [{path: patch-recursos.yaml}]
```

## 4. Fixar a imagem por digest — Altera

```bash
D=$(oc image info registry.access.redhat.com/ubi9/httpd-24:latest --filter-by-os=linux/amd64 -o json | jq -r .digest)
sed -i "s|    newTag: latest.*|    digest: $D|" /tmp/ac13/kustomize/overlays/prod/kustomization.yaml
oc diff -k /tmp/ac13/kustomize/overlays/prod
oc apply -k /tmp/ac13/kustomize/overlays/prod
```

## 5. Patches — Altera

```yaml
patches:
  - path: patch-recursos.yaml           # estratégico: objeto parcial, listas mescladas por nome
  - target: {kind: Service, name: ac13-loja}
    patch: |-                           # JSON 6902: operações com caminho exato
      - op: add
        path: /metadata/labels/exposto
        value: "interno"
```

## 6. Rótulos e seletores — Leitura

| Forma | Mexe no seletor? |
|---|---|
| `labels` + `includeSelectors: false` | não (use esta) |
| `labels` + `includeSelectors: true` | sim |
| `commonLabels` | **sim** → `field is immutable` em objetos existentes |

## 7. Limpar ConfigMaps antigos — Altera

```bash
oc apply -k /tmp/ac13/kustomize/overlays/dev --prune -l app.kubernetes.io/part-of=ac13-loja \
  --prune-allowlist=core/v1/ConfigMap --dry-run=server | grep pruned
```

Cada mudança deixa o ConfigMap anterior (útil para `rollout undo`). O prune apaga todos os antigos: mantenha o anterior se precisar de undo.

## 8. Templates: ler e processar — Leitura

```bash
oc process -f manifests/templates/ac13-template.yaml --parameters
oc process -f manifests/templates/ac13-template.yaml -p NOME=ac13-tpl-a -o yaml
oc get templates -n openshift | head
```

| Sintaxe | Resultado |
|---|---|
| `${NOME}` | texto |
| `${{REPLICAS}}` | valor JSON (número, booleano) |
| `generate: expression` | valor aleatório a cada processamento |

## 9. Instanciar um Template — Altera

```bash
oc process -f manifests/templates/ac13-template.yaml -p NOME=ac13-tpl-a -p MENSAGEM='instancia A' | oc apply -n ac13-kustomize -f -
printf 'NOME=ac13-tpl-b\nREPLICAS=2\n' > /tmp/ac13/b.env
oc process -f manifests/templates/ac13-template.yaml --param-file=/tmp/ac13/b.env | oc apply -n ac13-kustomize -f -
oc apply -f manifests/templates/ac13-template.yaml -n ac13-kustomize          # guarda no projeto
oc new-app --template=ac13-web -p NOME=ac13-tpl-c -n ac13-kustomize
```

## 10. Qual usar — Leitura

| Caso | Ferramenta |
|---|---|
| dev/homolog/prod da mesma aplicação | Kustomize |
| catálogo de autoatendimento com parâmetros | Template |
| distribuir aplicação com versões e rollback | Helm (Trilha 14) |

## 11. Diagnóstico — Leitura

| Mensagem | Causa | Cenário |
|---|---|---|
| `namespace ... does not match` | `-n` contra o `namespace` do overlay | [TS-040](../cenarios/troubleshooting/TS-040.md) |
| `failed to find unique target for patch` | nome do alvo mudou na base | [TS-041](../cenarios/troubleshooting/TS-041.md) |
| `cannot unmarshal string ... int32` | `${X}` em campo numérico | [TS-042](../cenarios/troubleshooting/TS-042.md) |
| `evalsymlink failure` / `no such file` | caminho errado em `resources` | KUS-014 |
| `field is immutable` | rótulo entrou no seletor | KUS-004 |
| `Required value` em parâmetro | parâmetro obrigatório ausente | KUS-011 |

## 12. Encerrar a trilha — Altera

```bash
oc delete project ac13-kustomize ac13-dev ac13-prod
oc delete project ac13-homolog --ignore-not-found
rm -rf /tmp/ac13
```
