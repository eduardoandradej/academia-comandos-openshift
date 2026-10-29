# Guia direto 19 — Troubleshooting transversal

> Perfil: `developer`. Projeto de treino: `ac19-casos`. Casos prontos em
> [`manifests/casos/`](../manifests/casos/README.md) (aplique sem ler: o arquivo traz só o sintoma).
> Exercícios completos: [trilhas/19-troubleshooting](../trilhas/19-troubleshooting/README.md).

## 1. O método dos sete andares

| Andar | Pergunta | Primeiro comando |
|---|---|---|
| 1 sessão | sou quem penso, no projeto certo? | `oc whoami; oc project -q` |
| 2 objeto | existe e está como declarei? | `oc get <tipo> <nome> -o yaml`; `oc diff -f` |
| 3 admissão | a API aceitou criar os pods? | `oc get events --field-selector reason=FailedCreate` |
| 4 agendamento | o pod tem nó? | `oc describe pod` → `FailedScheduling` |
| 5 início | a imagem baixou, a configuração existe? | `state.waiting.reason` |
| 6 execução | vivo e pronto? | `RESTARTS`, `lastState`, `Unhealthy`, `oc logs --previous` |
| 7 rede | o tráfego chega? | endpoints, `targetPort`, NetworkPolicy, Route |

Suba de andar só com evidência. Uma hipótese por vez. Depois de corrigir, **o sintoma mudou?**

## 2. Triagem de 60 segundos

```bash
triagem() {
  local ns=${1:-$(oc project -q)}
  echo "== workloads incompletos"; oc get deploy,sts -n "$ns" -o json | jq -r '.items[] | select((.status.readyReplicas // 0) < .spec.replicas) | "\(.kind)/\(.metadata.name) \(.status.readyReplicas // 0)/\(.spec.replicas)"'
  echo "== pods com problema"; oc get pods -n "$ns" -o json | jq -r '.items[] | select(.status.phase!="Succeeded") | . as $p | .status.containerStatuses[]? | select(.ready|not or .restartCount>0) | "\($p.metadata.name) pronto=\(.ready) reinícios=\(.restartCount) \(.state|keys[0]) \(.state[].reason // "")"'
  echo "== services sem endpoints"; for s in $(oc get svc -n "$ns" -o name | cut -d/ -f2); do [ -z "$(oc get endpointslices -n "$ns" -l kubernetes.io/service-name="$s" -o jsonpath='{.items[*].endpoints[?(@.conditions.ready==true)].addresses[0]}')" ] && echo "$s"; done
  echo "== últimos avisos"; oc get events -n "$ns" --field-selector type=Warning --sort-by=.lastTimestamp --no-headers | tail -5
}
triagem ac19-casos
```

## 3. Rodar um caso

```bash
oc apply -f manifests/casos/caso-01.yaml -n ac19-casos      # sintoma: a vitrine não responde pelo Service
triagem ac19-casos
# ... andar por andar ...
oc delete -f manifests/casos/caso-01.yaml -n ac19-casos
```

| Caso | Sintoma |
|---|---|
| 01 | a vitrine não responde pelo Service |
| 02 | o catálogo nunca fica estável |
| 03 | Route com "Application is not available" |
| 04 | o relatório nunca sai do Pending |
| 05 | o robô de escala recebe Forbidden |
| 06 | depois do "endurecimento", nada fala com nada (projeto `ac19-rede`) |
| 07 | o rollout não termina e o undo não volta |
| 08 | o fechamento diário "não roda" |
| 09 | aplicações que reiniciam ou somem |
| 10 | o overlay de produção não entrega o que promete (só renderização) |

Cada caso tem **mais de um defeito**: quando o sintoma muda, você achou um deles.

## 4. Evidências que mais ajudam

```bash
oc get pods -n ac19-casos -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.containerStatuses[0].state}{" "}{.status.containerStatuses[0].lastState}{"\n"}{end}'
oc logs <pod> -n ac19-casos --previous
oc describe pod <pod> -n ac19-casos | sed -n '/Events:/,$p'
oc get endpointslices -n ac19-casos -l kubernetes.io/service-name=<svc> -o jsonpath='{range .items[*].endpoints[*]}{.targetRef.name} {.conditions.ready}{"\n"}{end}'
oc auth can-i <verbo> <recurso> -n ac19-casos --as=system:serviceaccount:ac19-casos:<sa>
```

## 5. Linha do tempo e pós-incidente

| Conceito | Significa |
|---|---|
| gatilho | o que mudou (ex.: `oc set image`) |
| causa raiz | por que a mudança quebrou |
| agravante | o que impediu voltar ou perceber (ex.: `revisionHistoryLimit: 0`) |
| o que funcionou | proteções que limitaram o dano (`maxUnavailable: 0`, readiness) |

Relatório sem culpados: o foco é o sistema que permitiu o erro.

## 6. Armadilhas transversais

| Sintoma | Causa | Cenário |
|---|---|---|
| resposta errada com tudo verde | seletor pega duas versões | [TS-058](../cenarios/troubleshooting/TS-058.md) |
| IP do pod ok, Service não | porta nomeada inexistente | [TS-059](../cenarios/troubleshooting/TS-059.md) |
| falha intermitente | pod intruso com os mesmos rótulos | [TS-060](../cenarios/troubleshooting/TS-060.md) |

## 7. Encerrar a trilha

```bash
oc delete project ac19-casos ac19-rede --ignore-not-found
rm -rf /tmp/ac19 /tmp/ac19-*
```
