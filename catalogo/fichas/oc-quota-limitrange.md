# Ficha: ResourceQuota, LimitRange, ClusterResourceQuota e capacidade do nó

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL (projetos ac17) · LEITURA (nó) · MUTAÇÃO DE CLUSTER rotulada (CRQ, PriorityClass) · **Perfil mínimo:** admin (criar); developer (ler) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [ADM-001](../../trilhas/17-admin/exercicios/ADM-001.md), [ADM-003](../../trilhas/17-admin/exercicios/ADM-003.md), [ADM-004](../../trilhas/17-admin/exercicios/ADM-004.md), [ADM-005](../../trilhas/17-admin/exercicios/ADM-005.md), [ADM-007](../../trilhas/17-admin/exercicios/ADM-007.md), [ADM-009](../../trilhas/17-admin/exercicios/ADM-009.md), [ADM-014](../../trilhas/17-admin/exercicios/ADM-014.md)

## Quando usar

Para controlar quanto cada projeto pode reservar e diagnosticar por que um pod não é aceito ou não é agendado.

## Forma canônica

```bash
oc describe quota -n ac17-cotas
```

## Sintaxe

```text
oc describe quota|limitrange -n NS ; oc describe appliedclusterresourcequota -n NS
oc apply -f quota.yaml|limitrange.yaml -n NS            (admin)
oc describe node <nó> | sed -n '/Allocated resources:/,/Events:/p' ; oc adm top node
oc get clusterresourcequota ; oc get priorityclasses
oc adm node-logs <nó> --unit=kubelet --tail=N ; oc adm inspect ns/<projeto> --dest-dir=DIR
```

## Exemplos no HomeLab

```bash
oc apply -f manifests/admin/quota-completa.yaml -n ac17-cotas
oc apply -f manifests/admin/limitrange-completo.yaml -n ac17-cotas
oc describe quota -n ac17-cotas
oc describe limitrange -n ac17-cotas
oc apply -f manifests/admin/clusterresourcequota-ac17.yaml
oc describe node "$(oc get nodes -o jsonpath='{.items[0].metadata.name}')" | sed -n '/Allocated resources:/,/Events:/p'
```

## Flags principais

| Campo | Efeito |
|---|---|
| `hard` (quota) | limites: `requests.*`, `limits.*`, `pods`, `count/<recurso>` |
| `scopes` / `scopeSelector` | conta só pods BestEffort, Terminating, de uma PriorityClass... |
| `default` / `defaultRequest` (LimitRange) | preenche valores ausentes |
| `min` / `max` / `maxLimitRequestRatio` | recusa fora da faixa |
| `selector.labels` (CRQ) | projetos que dividem a cota |

## Comparação com comandos próximos

| | ResourceQuota | LimitRange | ClusterResourceQuota |
|---|---|---|---|
| Escopo | projeto | projeto (por contêiner/pod/PVC) | vários projetos |
| Limita | a soma | cada objeto | a soma entre projetos |
| Preenche padrões | não | sim | não |

## Antes e depois

Antes de criar workloads: `oc describe quota` e `oc describe limitrange`. Para Pending: Allocated resources do nó.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
Name:            ac17-computacao
Resource         Used   Hard
--------         ----   ----
limits.cpu       100m   1
pods             1      4
requests.cpu     25m    300m
```

## Erros comuns

- `must specify limits.cpu ...`: quota sem LimitRange com padrões (TS-052).
- `exceeded quota: <crq>` em projeto vazio: cota de cluster compartilhada (TS-053).
- `Insufficient cpu` com nó ocioso: requests reservados (TS-054).
- `maximum cpu usage per Container`: LimitRange (ADM-005).
- `no PriorityClass with name`: classe inexistente (ADM-009).

## Ajuda e documentação

```bash
oc explain resourcequota.spec
oc explain limitrange.spec.limits
oc explain clusterresourcequota.spec
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc delete resourcequota|limitrange <nome> -n <ns>` (admin); objetos de cluster por rótulo `academy.openshift.dev/trilha=17`.
