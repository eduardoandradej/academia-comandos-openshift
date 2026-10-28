# Guia direto 05 — Deployments e workloads

> Perfil: `developer`. Projeto de treino: `ac05-deploy`. Imagem: `registry.access.redhat.com/ubi9/httpd-24:latest`.
> Exercícios completos: [trilhas/05-deployments](../trilhas/05-deployments/README.md).

## 1. Criar um Deployment — Altera

```bash
oc new-project ac05-deploy
oc create deployment ac05-web --image=registry.access.redhat.com/ubi9/httpd-24:latest --replicas=2 --port=8080 -n ac05-deploy
oc rollout status deployment/ac05-web -n ac05-deploy
oc get deploy,rs,pods -n ac05-deploy -l app=ac05-web
```

| Comando | O que faz |
|---|---|
| `oc create deployment` | cria o Deployment (rótulo e seletor `app=<nome>`) |
| `--replicas=2` | quantos pods manter |
| `oc rollout status` | espera todos os pods ficarem prontos |
| `deploy,rs,pods` | mostra a cadeia: Deployment → ReplicaSet → Pods |

Apague um pod (`oc delete pod <nome> -n ac05-deploy`): o ReplicaSet cria outro na hora.

## 2. Escalar — Altera

```bash
oc scale deployment/ac05-web --replicas=1 -n ac05-deploy
oc scale deployment/ac05-web --replicas=0 -n ac05-deploy
oc scale deployment/ac05-web --replicas=2 --current-replicas=0 -n ac05-deploy
```

| Opção | O que faz |
|---|---|
| `--replicas=0` | "desliga" sem apagar |
| `--current-replicas=N` | só escala se o valor atual for N |

No HomeLab, no máximo **2** réplicas. Escalar não cria revisão nova.

## 3. Nova versão (rollout) e histórico — Altera

```bash
oc set env deployment/ac05-web VERSAO=v2 -n ac05-deploy
oc annotate deployment/ac05-web kubernetes.io/change-cause='v2: VERSAO=v2' --overwrite -n ac05-deploy
oc rollout status deployment/ac05-web -n ac05-deploy
oc rollout history deployment/ac05-web -n ac05-deploy
oc rollout history deployment/ac05-web --revision=2 -n ac05-deploy
```

| Comando | O que faz |
|---|---|
| `oc set env` | muda uma variável → muda o template → **nova revisão** |
| `kubernetes.io/change-cause` | texto que aparece na coluna CHANGE-CAUSE do histórico |
| `rollout history` | lista as revisões |
| `--revision=N` | mostra o conteúdo de uma revisão |

## 4. Desfazer — Altera

```bash
oc rollout undo deployment/ac05-web -n ac05-deploy
oc rollout undo deployment/ac05-web --to-revision=2 -n ac05-deploy
oc exec deploy/ac05-web -n ac05-deploy -- printenv VERSAO
```

| Comando | O que faz |
|---|---|
| `rollout undo` | volta à revisão anterior |
| `--to-revision=N` | volta a uma revisão específica (ela ganha um número novo) |

## 5. Reiniciar e agrupar mudanças — Altera

```bash
oc rollout restart deployment/ac05-web -n ac05-deploy

oc rollout pause deployment/ac05-web -n ac05-deploy
oc set env deployment/ac05-web VERSAO=v3 COR=azul -n ac05-deploy
oc set resources deployment/ac05-web --requests=cpu=20m,memory=32Mi --limits=cpu=100m,memory=128Mi -n ac05-deploy
oc rollout resume deployment/ac05-web -n ac05-deploy
```

| Comando | O que faz |
|---|---|
| `rollout restart` | recria todos os pods com a **mesma** configuração |
| `rollout pause` | acumula mudanças sem recriar pods |
| `rollout resume` | aplica tudo de uma vez, em **uma** revisão |

Nunca deixe um Deployment pausado esquecido.

## 6. Trocar imagem, variáveis e recursos — Altera

```bash
oc get deployment ac05-web -n ac05-deploy -o jsonpath='{.spec.template.spec.containers[*].name}{"\n"}'   # httpd-24
D=$(oc get pods -n ac05-deploy -l app=ac05-web -o jsonpath='{.items[0].status.containerStatuses[0].imageID}')
oc set image deployment/ac05-web httpd-24=$D -n ac05-deploy
oc set env deployment/ac05-web --list -n ac05-deploy
oc set env deployment/ac05-web COR- -n ac05-deploy
oc set resources deployment/ac05-web --limits=memory=96Mi -n ac05-deploy
```

| Comando | O que faz |
|---|---|
| `oc set image <deploy> <contêiner>=<imagem>` | troca a imagem (aqui, pela mesma imagem fixada pelo digest) |
| `oc set env ... --list` | lista as variáveis |
| `oc set env ... CHAVE-` | remove a variável |
| `oc set resources` | requests e limits |

## 7. Estratégia de atualização — Altera

```bash
oc patch deployment ac05-web -n ac05-deploy --type=merge \
  -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
oc patch deployment ac05-web -n ac05-deploy --type=merge \
  -p '{"spec":{"strategy":{"type":"Recreate","rollingUpdate":null}}}'
```

| Estratégia | Como troca | Fica fora do ar? |
|---|---|---|
| `RollingUpdate` (padrão) | sobe novos e desce antigos aos poucos | não |
| `Recreate` | derruba todos e depois sobe os novos | sim, por alguns segundos |

`maxSurge` = pods a mais permitidos durante a troca; `maxUnavailable` = pods a menos permitidos.

## 8. Estado do Deployment — Leitura

```bash
oc get deployment ac05-web -n ac05-deploy
oc get deployment ac05-web -n ac05-deploy -o jsonpath='{range .status.conditions[*]}{.type}={.status} ({.reason}){"\n"}{end}'
oc describe deployment ac05-web -n ac05-deploy
```

| Condição / motivo | Significado |
|---|---|
| `Available=True` | pods suficientes prontos |
| `Progressing` / `NewReplicaSetAvailable` | rollout concluído |
| `Progressing` / `ReplicaSetUpdated` | rollout em andamento |
| `Progressing` / `ProgressDeadlineExceeded` | travou: investigue e use `rollout undo` |

## 9. Não mexa no ReplicaSet — Leitura

```bash
oc get rs -n ac05-deploy -l app=ac05-web
```

O Deployment é o dono dos ReplicaSets: se você escalar ou apagar um ReplicaSet, o Deployment desfaz. **Altere sempre o Deployment.**

## 10. oc new-app — Altera

```bash
oc new-app --image=registry.access.redhat.com/ubi9/httpd-24:latest --name=ac05-app -l app.kubernetes.io/part-of=ac05 -n ac05-deploy
oc get all,imagestreams -n ac05-deploy -l app.kubernetes.io/part-of=ac05
oc delete deployment,service,imagestream -l app.kubernetes.io/part-of=ac05 -n ac05-deploy
```

| Comando | O que faz |
|---|---|
| `oc new-app --image` | cria Deployment, Service e (para imagens externas) ImageStream de uma vez |
| `-l` | rótulo em tudo o que foi criado (facilita a limpeza) |

## 11. Jobs — Altera

```bash
oc create job ac05-oi --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac05-deploy -- /bin/sh -c 'echo oi'
oc wait --for=condition=complete job/ac05-oi -n ac05-deploy --timeout=120s
oc logs job/ac05-oi -n ac05-deploy
oc apply -f manifests/apps-exemplo/job-lote.yaml -n ac05-deploy
oc get job ac05-lote -n ac05-deploy
oc delete job ac05-oi ac05-lote -n ac05-deploy
```

| Campo | O que faz |
|---|---|
| `completions` | quantas execuções com sucesso são necessárias |
| `parallelism` | quantas ao mesmo tempo |
| `backoffLimit` | quantas falhas antes de desistir |
| `ttlSecondsAfterFinished` | apaga o Job sozinho depois de terminar |

## 12. CronJobs — Altera

```bash
oc create cronjob ac05-relatorio --image=registry.access.redhat.com/ubi9/httpd-24:latest \
  --schedule='15 3 * * *' -n ac05-deploy -- /bin/sh -c 'date'
oc patch cronjob ac05-relatorio -n ac05-deploy -p '{"spec":{"suspend":true,"timeZone":"America/Sao_Paulo"}}'
oc create job ac05-relatorio-manual --from=cronjob/ac05-relatorio -n ac05-deploy
oc logs job/ac05-relatorio-manual -n ac05-deploy
oc delete job ac05-relatorio-manual -n ac05-deploy; oc delete cronjob ac05-relatorio -n ac05-deploy
```

| Item | Significado |
|---|---|
| `--schedule='15 3 * * *'` | minuto hora dia mês dia-da-semana (aqui: todo dia às 3h15) |
| `suspend: true` | não agenda execuções novas |
| `--from=cronjob/...` | dispara uma execução agora |

No SNO, mantenha CronJobs suspensos e dispare manualmente.

## 13. DaemonSet — Altera

```bash
oc apply -f manifests/apps-exemplo/daemonset-mini.yaml -n ac05-deploy
oc get daemonset ac05-ds -n ac05-deploy
oc delete daemonset ac05-ds -n ac05-deploy
```

Um pod em cada nó (no SNO, um só). DaemonSet não tem `replicas` e não se escala.

## 14. Manifesto declarativo — Altera

```bash
oc get deployment ac05-web -n ac05-deploy -o json \
  | jq 'del(.status, .metadata.uid, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .metadata.managedFields)' \
  > /tmp/ac05-web.json
oc diff -f /tmp/ac05-web.json -n ac05-deploy      # sem saída = cluster igual ao arquivo
oc apply -f /tmp/ac05-web.json -n ac05-deploy
```

| Comando | O que faz |
|---|---|
| `jq 'del(...)'` | tira os campos que o cluster preenche |
| `oc diff -f` | mostra o que o `apply` mudaria |
| `oc apply -f` | aplica o arquivo |

## 15. Erros comuns — Leitura

| Sintoma | Primeiro comando | Causa típica |
|---|---|---|
| `exceeded its progress deadline` | `oc get pods -l app=<nome>` + `oc describe pod` | imagem inexistente ou probe falhando ([TS-016](../cenarios/troubleshooting/TS-016.md)) |
| Job `Failed`, `BackoffLimitExceeded` | `oc logs -l job-name=<job> --prefix` | a tarefa sai com erro ([TS-017](../cenarios/troubleshooting/TS-017.md)) |
| `1/3` réplicas e nenhum pod Pending | `oc describe rs -l app=<nome>` (Events) | quota do projeto ([TS-018](../cenarios/troubleshooting/TS-018.md)) |

## 16. Encerrar a trilha — Altera

```bash
oc delete project ac05-deploy
oc get project ac05-deploy      # até NotFound
rm -f /tmp/ac05-*
```
