# Ficha: `oc apply`, `diff`, `replace`, `patch` e `--dry-run`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL (com diff e dry-run antes) · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [DCL-001](../../trilhas/12-declarativo/exercicios/DCL-001.md), [DCL-002](../../trilhas/12-declarativo/exercicios/DCL-002.md), [DCL-004](../../trilhas/12-declarativo/exercicios/DCL-004.md), [DCL-005](../../trilhas/12-declarativo/exercicios/DCL-005.md), [DCL-006](../../trilhas/12-declarativo/exercicios/DCL-006.md), [DCL-008](../../trilhas/12-declarativo/exercicios/DCL-008.md), [DCL-014](../../trilhas/12-declarativo/exercicios/DCL-014.md)

## Quando usar

Para gerenciar recursos por arquivos (estado desejado), revisando cada mudança antes de aplicá-la.

## Forma canônica

```bash
oc apply -f app.yaml -n ac12-declarativo
```

## Sintaxe

```text
oc COMANDO --dry-run=client -o yaml                 # gerar
oc apply --dry-run=server [--validate=strict] -f F    # validar
oc diff -f F                                          # 0 igual, 1 diferente, >1 erro
oc apply -f F|DIR [-R] [--server-side --field-manager=M [--force-conflicts]] [--prune -l SEL --prune-allowlist=...]
oc replace [--force] -f F ; oc delete -f F [--cascade=foreground|orphan]
oc patch TIPO/NOME --type=strategic|merge|json -p '...' [--dry-run=server -o yaml] [--local -f F]
```

## Exemplos no HomeLab

```bash
oc create deployment ac12-web --image=registry.access.redhat.com/ubi9/httpd-24:latest --dry-run=client -o yaml > deploy.yaml
oc apply --dry-run=server --validate=strict -f app.yaml -n ac12-declarativo
oc diff -f app.yaml -n ac12-declarativo; echo $?
oc apply -f app.yaml -n ac12-declarativo
oc apply view-last-applied deployment/ac12-web -n ac12-declarativo
oc patch deployment ac12-web --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/env/0/value","value":"x"}]' -n ac12-declarativo
oc label --local -f deploy.yaml ambiente=prod -o yaml
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--dry-run=client` / `server` | não grava; `server` passa pela admissão |
| `--validate=strict` | campo desconhecido vira erro |
| `--server-side --field-manager` | apply no servidor, com dono por campo |
| `--prune -l --prune-allowlist` | apaga o que saiu do diretório (sempre com dry-run antes) |
| `--type` (patch) | `strategic` (padrão, listas por chave), `merge` (substitui listas), `json` (operações) |
| `--local` | edita o arquivo, sem cluster |

## Comparação com comandos próximos

| | `create` | `apply` | `replace` | `patch` |
|---|---|---|---|---|
| Objeto não existe | cria | cria | erro | erro |
| Objeto existe | erro | mescla (3 vias) | substitui inteiro | muda só o enviado |
| Idempotente | não | sim | sim, com cuidado | depende |

## Antes e depois

Antes de aplicar: `oc diff` (código 1 = há mudança). Depois: `oc diff` de novo deve dar 0.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
configmap/ac12-pagina unchanged
deployment.apps/ac12-web configured
service/ac12-web unchanged
route.route.openshift.io/ac12-web unchanged
```

## Erros comuns

- `unknown field` / `strict decoding error`: digitação (DCL-002).
- `AlreadyExists`: use `apply` (DCL-003).
- `the object has been modified`: `resourceVersion` no arquivo (DCL-007).
- `field is immutable`: seletor e afins (TS-037).
- apply desfaz escala: `replicas` no arquivo (TS-038).
- `Apply failed with N conflict(s)`: SSA (TS-039).

## Ajuda e documentação

```bash
oc apply --help
oc diff --help
oc patch --help
oc replace --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc apply` da versão anterior do arquivo (Git); `oc rollout undo` para o template; `oc delete -f`.
