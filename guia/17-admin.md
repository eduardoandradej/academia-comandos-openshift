# Guia direto 17 — Administração de recursos

> Perfil: **`admin`** (o `developer` testa as recusas). Projeto de treino: `ac17-cotas`. Nunca altere o nó, a rede
> ou `openshift-*`. Exercícios completos: [trilhas/17-admin](../trilhas/17-admin/README.md).

## 1. Capacidade do nó — Leitura

```bash
N=$(oc get nodes -o jsonpath='{.items[0].metadata.name}')
oc get node "$N" -o jsonpath='{.status.capacity}{"\n"}{.status.allocatable}{"\n"}'
oc describe node "$N" | sed -n '/Allocated resources:/,/Events:/p'
oc adm top node
```

| Número | Significa |
|---|---|
| capacidade | o hardware |
| alocável | o que sobra para pods |
| **reservado** (requests) | o que o agendador usa para encaixar pods |
| uso | consumo real agora |

## 2. Quotas — Altera

```bash
oc new-project ac17-cotas
oc policy add-role-to-user admin developer -n ac17-cotas
oc apply -f manifests/admin/quota-completa.yaml -n ac17-cotas
oc describe quota -n ac17-cotas
```

| Tipo | Exemplo |
|---|---|
| computação | `requests.cpu`, `limits.memory`, `pods` |
| objetos | `count/deployments.apps`, `services` |
| escopo | `BestEffort`, `PriorityClass` |

Várias quotas valem juntas: a mais restritiva decide.

## 3. As três recusas de quota — Leitura

| Mensagem | Causa |
|---|---|
| `must specify limits.cpu ...` | pod sem resources e sem LimitRange ([TS-052](../cenarios/troubleshooting/TS-052.md)) |
| `exceeded quota ... requested ... limited` | soma passou do limite |
| `count/deployments.apps` excedido | contagem de objetos |

## 4. LimitRange — Altera

```bash
oc apply -f manifests/admin/limitrange-completo.yaml -n ac17-cotas
oc describe limitrange -n ac17-cotas
```

| Campo | Efeito |
|---|---|
| `defaultRequest` / `default` | preenche valores ausentes |
| `min` / `max` | recusa fora da faixa |
| `maxLimitRequestRatio` | recusa limit > N × request |
| `type: Pod` | limite para a soma dos contêineres |

Ordem da admissão: o LimitRange **preenche** antes de a quota **somar**. Por isso quota + LimitRange é a baseline.

## 5. Cota para vários projetos — Altera

```bash
oc apply -f manifests/admin/clusterresourcequota-ac17.yaml
oc label namespace ac17-equipe-a academy.openshift.dev/equipe=ac17
oc describe clusterresourcequota ac17-equipe
oc describe appliedclusterresourcequota -n ac17-equipe-a     # o developer também vê
```

`oc get resourcequota` não mostra cotas de cluster ([TS-053](../cenarios/troubleshooting/TS-053.md)).

## 6. Agendamento e prioridade — Leitura

```bash
oc get node "$N" -o jsonpath='{.spec.taints}{"\n"}'
oc get scheduler cluster -o jsonpath='{.spec}{"\n"}'
oc get priorityclasses
oc apply -f manifests/admin/priorityclass-ac17-baixa.yaml    # valor -10, preemptionPolicy: Never
```

Nunca crie prioridade alta (desaloja outros pods) nem altere rótulos/taints do nó.

## 7. Varredura diária — Leitura

```bash
oc get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded
oc get events -A --field-selector type=Warning --sort-by=.lastTimestamp | tail -15
oc get co
oc get --raw '/readyz?verbose' | tail -3
oc get csr
```

## 8. Logs do nó sem entrar nele — Leitura

```bash
oc adm node-logs "$N" --unit=kubelet --tail=20
oc adm node-logs "$N" --unit=crio --since=-10m --tail=20
```

Prefira isto a `oc debug node` (pod privilegiado no único nó) e a SSH.

## 9. Coleta para suporte — Leitura

```bash
oc adm inspect ns/ac17-cotas --dest-dir=/tmp/ac17-coleta && du -sh /tmp/ac17-coleta
```

`must-gather` coleta o cluster inteiro: **só planejar** (espaço no HD, autorização, revisão de dados sensíveis).

## 10. Diagnóstico — Leitura

| Camada | Sintoma |
|---|---|
| quota | `exceeded quota`, `must specify` (no `oc` ou no ReplicaSet) |
| LimitRange | `maximum/minimum ... per Container` |
| prioridade | `no PriorityClass with name` |
| agendamento | `Pending` + `Insufficient cpu`/`node selector` ([TS-054](../cenarios/troubleshooting/TS-054.md)) |
| pressão no nó | `Evicted` + `low on resource` |

## 11. Encerrar a trilha — Altera

```bash
oc delete project ac17-cotas ac17-equipe-a ac17-equipe-b --ignore-not-found
oc delete clusterresourcequota,priorityclass -l academy.openshift.dev/managed-by=academia,academy.openshift.dev/trilha=17
rm -rf /tmp/ac17-*
ac-dev
```
