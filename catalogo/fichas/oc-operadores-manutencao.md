# Ficha: ClusterVersion, ClusterOperators, OLM e MachineConfig (somente leitura)

> **Impacto:** LEITURA (VERMELHO para qualquer mudança) · **Perfil mínimo:** admin (somente leitura) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [OPS-001](../../trilhas/18-operadores/exercicios/OPS-001.md), [OPS-002](../../trilhas/18-operadores/exercicios/OPS-002.md), [OPS-003](../../trilhas/18-operadores/exercicios/OPS-003.md), [OPS-006](../../trilhas/18-operadores/exercicios/OPS-006.md), [OPS-009](../../trilhas/18-operadores/exercicios/OPS-009.md), [OPS-011](../../trilhas/18-operadores/exercicios/OPS-011.md), [OPS-014](../../trilhas/18-operadores/exercicios/OPS-014.md)

## Quando usar

Para acompanhar a saúde da plataforma, planejar manutenções e diagnosticar operadores sem alterar nada.

## Forma canônica

```bash
oc get co
```

## Sintaxe

```text
oc get clusterversion ; oc adm upgrade   (sem argumentos: só exibe)
oc get co [-o json | jq '.items[].status.conditions']
oc get co <x> -o jsonpath='{.status.relatedObjects}'
oc get catalogsources,packagemanifests -n openshift-marketplace ; oc get subscriptions,csv,installplan,operatorgroups -A
oc get mcp,mc ; oc get crd
oc logs deploy/<operador> -n <ns>-operator --tail=50
```

## Exemplos no HomeLab

```bash
oc get clusterversion version -o jsonpath='{.status.desired.version} {.spec.channel}{"\n"}'
oc get co --no-headers | awk '$3!="True" || $4!="False" || $5!="False"'
oc get co ingress -o json | jq -r '.status.relatedObjects[] | "\(.resource) \(.namespace // "-") \(.name)"'
oc get subscriptions -A
oc get mcp master -o jsonpath='{.status.configuration.name}{"\n"}'
oc apply --dry-run=server -f subscription.yaml -n ac18-ops
```

## Flags principais

| Objeto | Leia | Nunca (na Academia) |
|---|---|---|
| `clusterversion` | versão, histórico, condições | `oc adm upgrade --to`, `spec.overrides` |
| ClusterOperator / CR do operador | condições, relatedObjects | `managementState`, `unsupportedConfigOverrides` |
| OLM | Subscription, CSV, InstallPlan | aprovar InstallPlan, criar Subscription real |
| `mcp`/`mc` | renderizado, condições | criar/editar MachineConfig |
| nó | condições, `unschedulable` | `cordon`, `drain`, reboot |

## Comparação com comandos próximos

| Condição do CO | Ideal | Se diferente |
|---|---|---|
| Available | True | componente fora |
| Progressing | False | mudando: espere e meça |
| Degraded | False | investigar (OPS-014) |
| Upgradeable | True | bloqueia atualização menor |

## Antes e depois

Antes de qualquer conclusão: `lastTransitionTime` (há quanto tempo?) e a tendência em leituras repetidas.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME      VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE
ingress   4.22.0    True        False         False      3d
```

## Erros comuns

- Vários `Progressing` após religar o SNO: reconciliação normal (TS-055).
- MCP `Updating` sem fim: MachineConfig novo ou inválido (TS-056).
- Operador OLM desatualizado: InstallPlan esperando aprovação (TS-057).
- `Upgradeable=False`: admin-acks, overrides ou operador (OPS-011).

## Ajuda e documentação

```bash
oc adm upgrade --help
oc explain clusteroperator.status
oc explain subscription.spec
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Não há o que desfazer: a trilha é somente leitura (as mudanças ficam como plano escrito).
