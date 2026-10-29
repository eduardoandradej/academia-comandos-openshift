# Ficha: Diagnóstico transversal: os sete andares e a triagem

> **Impacto:** LEITURA · **Perfil mínimo:** developer (admin só para o nó e o cluster) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [DIA-001](../../trilhas/19-troubleshooting/exercicios/DIA-001.md), [DIA-002](../../trilhas/19-troubleshooting/exercicios/DIA-002.md), [DIA-003](../../trilhas/19-troubleshooting/exercicios/DIA-003.md), [DIA-008](../../trilhas/19-troubleshooting/exercicios/DIA-008.md), [DIA-013](../../trilhas/19-troubleshooting/exercicios/DIA-013.md), [DIA-015](../../trilhas/19-troubleshooting/exercicios/DIA-015.md)

## Quando usar

Para chegar à causa de qualquer "não funciona" com um método fixo, do terminal até a rede, sem corrigir o andar errado.

## Forma canônica

```bash
oc get events -n ac19-casos --field-selector type=Warning --sort-by=.lastTimestamp
```

## Sintaxe

```text
1 sessão:      oc whoami; oc project -q
2 objeto:      oc get <tipo> <nome> -o yaml ; oc diff -f <manifesto>
3 admissão:    oc get events --field-selector reason=FailedCreate
4 agendamento: oc describe pod <p> | sed -n '/Events:/,$p'   (FailedScheduling)
5 início:      .status.containerStatuses[].state.waiting.reason
6 execução:    RESTARTS, lastState.terminated, eventos Unhealthy, oc logs --previous
7 rede:        oc get endpointslices -l kubernetes.io/service-name=<svc>; oc get networkpolicy; route status
```

## Exemplos no HomeLab

```bash
oc get deploy,rs,pods -n ac19-casos
oc get pods -n ac19-casos -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.containerStatuses[0].state}{"\n"}{end}'
oc get events -n ac19-casos --field-selector reason=FailedCreate
oc logs <pod> -n ac19-casos --previous
oc get endpointslices -n ac19-casos -l kubernetes.io/service-name=<svc>
oc auth can-i <verbo> <recurso> -n ac19-casos --as=system:serviceaccount:ac19-casos:<sa>
```

## Flags principais

| Evidência | Andar |
|---|---|
| `Forbidden`, `Unauthorized` | 1 (sessão/permissão) |
| `NotFound`, `AlreadyExists`, `invalid` | 2 (objeto) |
| `exceeded quota`, `must specify`, `unable to validate against any SCC` | 3 (admissão) |
| `FailedScheduling` | 4 (agendamento) |
| `ErrImagePull`, `CreateContainerConfigError`, `InvalidImageName` | 5 (início) |
| `CrashLoopBackOff`, `OOMKilled`, `Unhealthy` | 6 (execução) |
| endpoints vazios, timeout, 503 | 7 (rede) |

## Comparação com comandos próximos

| Sintoma | Primeiro andar a olhar |
|---|---|
| Deployment `0/N` sem pods | 3 |
| pod `Pending` | 4 |
| pod `Running 0/1` | 6 |
| pod `1/1` e o Service não responde | 7 |

## Antes e depois

Antes de corrigir: escreva a hipótese. Depois de corrigir: o sintoma mudou? Volte à triagem até ele sumir.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
== workloads incompletos
Deployment/ac19-c1 0/1
== services sem endpoints
ac19-c1
```

## Erros comuns

- Resposta errada com tudo verde: seletor amplo (TS-058).
- IP do pod ok, Service não: porta nomeada (TS-059).
- Falha intermitente: endpoint intruso (TS-060).
- Sintoma muda após a correção: havia mais de um defeito (DIA-003 a DIA-012).

## Ajuda e documentação

```bash
oc describe --help
oc get events --help
oc explain pod.status.containerStatuses
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Diagnóstico não altera nada; as correções de cada caso estão nos gabaritos DIA-003 a DIA-012.
