# Ficha: Helm 3: `template`, `install`, `upgrade`, `rollback`, `test`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL (releases no projeto) · **Perfil mínimo:** developer (confira `oc whoami` antes) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [HLM-001](../../trilhas/14-helm/exercicios/HLM-001.md), [HLM-003](../../trilhas/14-helm/exercicios/HLM-003.md), [HLM-004](../../trilhas/14-helm/exercicios/HLM-004.md), [HLM-005](../../trilhas/14-helm/exercicios/HLM-005.md), [HLM-006](../../trilhas/14-helm/exercicios/HLM-006.md), [HLM-010](../../trilhas/14-helm/exercicios/HLM-010.md), [HLM-014](../../trilhas/14-helm/exercicios/HLM-014.md)

## Quando usar

Para instalar e atualizar uma aplicação empacotada (chart) com valores, histórico de revisões e rollback.

## Forma canônica

```bash
helm install loja manifests/helm/ac14-loja -n ac14-helm
```

## Sintaxe

```text
helm lint|template CHART [-f valores.yaml] [--set k=v] [--show-only templates/x.yaml]
helm install|upgrade [--install] NOME CHART -n NS [-f] [--set] [--wait --timeout T | --atomic] [--dry-run=server]
helm list -n NS [-a] ; helm status|history NOME -n NS ; helm get values|manifest|notes NOME [--all] [--revision N]
helm rollback NOME [N] -n NS ; helm test NOME -n NS ; helm uninstall NOME -n NS [--keep-history]
helm repo add|update|list|remove ; helm search repo T ; helm show values|chart REPO/CHART ; helm pull --untar
```

## Exemplos no HomeLab

```bash
helm lint manifests/helm/ac14-loja
helm template loja manifests/helm/ac14-loja -f manifests/helm/ac14-loja/values-prod.yaml --show-only templates/deployment.yaml
helm install loja manifests/helm/ac14-loja -n ac14-helm
helm upgrade loja manifests/helm/ac14-loja -n ac14-helm -f manifests/helm/ac14-loja/values-prod.yaml --atomic --timeout 2m
helm history loja -n ac14-helm
helm rollback loja 1 -n ac14-helm
helm test loja -n ac14-helm
```

## Flags principais

| Flag | Efeito |
|---|---|
| `-f` / `--set` | valores (o último vence; `--set` vence `-f`) |
| `--reuse-values` | reaproveita os valores calculados da revisão anterior (ignora defaults novos) |
| `--wait --timeout` | espera os pods ficarem prontos |
| `--atomic` | `--wait` + rollback automático se falhar |
| `--dry-run=server` | renderiza e valida no servidor, sem instalar |
| `--skip-tests` (template) | não inclui os pods de teste |

## Comparação com comandos próximos

| | Helm | Kustomize | Template |
|---|---|---|---|
| Estado no cluster | release (Secrets) | nenhum | opcional |
| Rollback | `helm rollback` | Git + `apply -k` | — |
| Parâmetros | valores + schema | overlays | parâmetros |

## Antes e depois

Antes: `oc whoami` = developer; `helm lint` e `helm template`. Depois: `helm status`, `helm test`, `helm get manifest | oc diff -f -`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME   NAMESPACE   REVISION   UPDATED   STATUS     CHART            APP VERSION
loja   ac14-helm   3          ...       deployed   ac14-loja-0.1.0  2.4
```

## Erros comuns

- `another operation ... is in progress`: revisão `pending-*` (TS-043).
- `invalid ownership metadata`: objeto criado fora do Helm (TS-044).
- valor novo do chart ignorado: `--reuse-values` (TS-045).
- `values don't meet the specifications of the schema`: valor inválido (HLM-008).
- release `deployed` com pods quebrados: faltou `--wait`/`--atomic` (HLM-010).

## Ajuda e documentação

```bash
helm --help
helm upgrade --help
helm show values CHART
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`helm rollback NOME N`; `helm uninstall NOME` (apaga os objetos da release).
