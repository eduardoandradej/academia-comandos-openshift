# Guia direto 11 — Resiliência

> Perfil: `developer`. Projeto de treino: `ac11-resiliencia`. Carga de CPU só dentro de `limits.cpu: 100m`; HPA até 2
> réplicas. Exercícios completos: [trilhas/11-resiliencia](../trilhas/11-resiliencia/README.md).

## 1. Requests e limits — Altera

```bash
oc new-project ac11-resiliencia
oc create deployment ac11-app --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac11-resiliencia
oc set resources deployment/ac11-app --requests=cpu=50m,memory=64Mi --limits=cpu=100m,memory=128Mi -n ac11-resiliencia
oc get pod -n ac11-resiliencia -l app=ac11-app -o jsonpath='{.items[0].status.qosClass}{"\n"}'
```

| Número | Quem usa | Efeito |
|---|---|---|
| `requests` | agendador e quota | reserva no nó |
| `limits.cpu` | kernel | **estrangula** acima do teto (fica lento) |
| `limits.memory` | kernel | **mata** acima do teto (OOMKilled) |

## 2. Medir consumo — Leitura

```bash
oc adm top pods -n ac11-resiliencia --containers
oc exec deploy/ac11-app -n ac11-resiliencia -- cat /sys/fs/cgroup/cpu.stat | grep throttled
```

`oc adm top` usa a Metrics API (amostras recentes, sem histórico). `nr_throttled` crescendo = CPU no teto.

## 3. Readiness — Altera

```bash
oc expose deployment/ac11-app --port=8080 -n ac11-resiliencia
oc set probe deployment/ac11-app --readiness --open-tcp=8080 --period-seconds=5 -n ac11-resiliencia
oc get pods -n ac11-resiliencia -l app=ac11-app               # READY 1/1
```

| Tipo | Flag | Sucesso |
|---|---|---|
| HTTP | `--get-url=http://:8080/caminho` | código 200–399 |
| TCP | `--open-tcp=8080` | porta aberta |
| comando | `-- test -f /tmp/pronto` | saída 0 |

A página padrão do httpd da UBI responde **403** em `/`: uma probe HTTP em `/` falha.

## 4. Liveness e startup — Altera

```bash
oc set probe deployment/ac11-app --liveness --open-tcp=8080 --period-seconds=10 --failure-threshold=3 -n ac11-resiliencia
oc set probe deployment/ac11-app --startup --open-tcp=8080 --period-seconds=2 --failure-threshold=30 -n ac11-resiliencia
oc set probe deployment/ac11-app --startup --remove -n ac11-resiliencia
```

| Probe | Ao falhar |
|---|---|
| readiness | sai do Service (não reinicia) |
| liveness | reinicia o contêiner |
| startup | segura as outras até passar; tolera `period × failureThreshold` segundos |

Tempo até agir ≈ `periodSeconds × failureThreshold`. Liveness deve ser barata e mais tolerante que a readiness.

## 5. Autocura — Altera

```bash
oc exec deploy/ac11-app -n ac11-resiliencia -- sh -c 'kill 1'      # kubelet reinicia o contêiner (RESTARTS +1)
oc delete pod -n ac11-resiliencia -l app=ac11-app                  # ReplicaSet cria pod novo
oc get pods -n ac11-resiliencia -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount
```

`CrashLoopBackOff`: o kubelet espera 10 s, 20 s, 40 s... (até 5 min) entre tentativas.

## 6. Desligamento gracioso — Altera

```bash
oc patch deployment ac11-app -n ac11-resiliencia --type=json -p '[
 {"op":"add","path":"/spec/template/spec/terminationGracePeriodSeconds","value":20},
 {"op":"add","path":"/spec/template/spec/containers/0/lifecycle","value":{"preStop":{"exec":{"command":["sh","-c","sleep 10"]}}}}]'
```

Ordem: sai dos endpoints → `preStop` → SIGTERM → SIGKILL ao fim do prazo (contado desde o início).

## 7. Rollout sem indisponibilidade — Altera

```bash
oc scale deployment/ac11-app --replicas=2 -n ac11-resiliencia
oc patch deployment ac11-app -n ac11-resiliencia --type=merge \
  -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxUnavailable":0,"maxSurge":1}}}}'
oc rollout restart deployment/ac11-app -n ac11-resiliencia && oc rollout status deployment/ac11-app -n ac11-resiliencia
```

Receita: readiness + `maxUnavailable: 0` + `maxSurge: 1` + `preStop` curto.

## 8. HPA — Altera

```bash
oc autoscale deployment/ac11-app --min=1 --max=2 --cpu-percent=50 -n ac11-resiliencia
oc exec deploy/ac11-app -n ac11-resiliencia -- timeout 120 sh -c 'while :; do :; done' &
oc get hpa ac11-app -n ac11-resiliencia -w            # Ctrl+C depois de ver REPLICAS 2
oc describe hpa ac11-app -n ac11-resiliencia | sed -n '/Conditions:/,$p'
```

| Condição | Se `False` |
|---|---|
| `AbleToScale` | em janela de estabilização |
| `ScalingActive` | sem métricas ou sem `requests.cpu` (`<unknown>`) |
| `ScalingLimited` (`True`) | quereria passar de min/max |

## 9. PodDisruptionBudget — Altera

```bash
oc create poddisruptionbudget ac11-pdb --selector=app=ac11-app --min-available=1 -n ac11-resiliencia
oc get pdb -n ac11-resiliencia                        # ALLOWED DISRUPTIONS
oc delete pdb ac11-pdb -n ac11-resiliencia
```

O PDB limita evicções voluntárias (drain, upgrade). Com 1 réplica e `minAvailable: 1`, nenhuma evicção passa — em um
SNO, isso trava manutenções. Nunca drene o nó para testar.

## 10. Diagnóstico — Leitura

| Sintoma | Causa típica | Cenário |
|---|---|---|
| reinícios em série, app saudável | liveness com timeout curto | [TS-034](../cenarios/troubleshooting/TS-034.md) |
| `TARGETS <unknown>` | sem `requests.cpu` ou sem métricas | [TS-035](../cenarios/troubleshooting/TS-035.md) |
| `Cannot evict pod ... disruption budget` | `ALLOWED DISRUPTIONS 0` | [TS-036](../cenarios/troubleshooting/TS-036.md) |
| `Running 0/1` | readiness falhando (ex.: 403 em `/`) | RES-004 |
| lento, sem reinício | CPU estrangulada | RES-003 |
| `OOMKilled` / 137 | passou do `limits.memory` | [TS-015](../cenarios/troubleshooting/TS-015.md) |

## 11. Encerrar a trilha — Altera

```bash
pkill -f 'oc exec .*ac11-resiliencia' || true
oc delete project ac11-resiliencia
oc get project ac11-resiliencia      # até NotFound
```
