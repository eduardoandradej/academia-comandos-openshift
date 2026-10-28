# Ficha: `oc create job` e `oc create cronjob`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [DEP-010](../../trilhas/05-deployments/exercicios/DEP-010.md), [DEP-011](../../trilhas/05-deployments/exercicios/DEP-011.md)

## Quando usar

Para tarefas que terminam (Job) e tarefas agendadas (CronJob), inclusive disparo manual a partir de um CronJob.

## Forma canônica

```bash
oc create job ac05-oi --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac05-deploy -- echo oi
```

## Sintaxe

```text
oc create job NOME --image=IMG [-- COMANDO]
oc create job NOME --from=cronjob/CRON
oc create cronjob NOME --image=IMG --schedule='m h d M s' [-- COMANDO]
```

## Exemplos no HomeLab

```bash
oc create job ac05-oi --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac05-deploy -- /bin/sh -c 'echo oi'
oc wait --for=condition=complete job/ac05-oi -n ac05-deploy --timeout=120s
oc logs job/ac05-oi -n ac05-deploy
oc create cronjob ac05-relatorio --image=registry.access.redhat.com/ubi9/httpd-24:latest --schedule='15 3 * * *' -n ac05-deploy -- date
oc patch cronjob ac05-relatorio -n ac05-deploy -p '{"spec":{"suspend":true}}'
oc create job ac05-manual-1 --from=cronjob/ac05-relatorio -n ac05-deploy
```

## Flags principais

| Campo (Job) | Efeito |
|---|---|
| `completions` / `parallelism` | quantas conclusões / quantas por vez |
| `backoffLimit` | falhas aceitas antes de desistir |
| `activeDeadlineSeconds` | tempo máximo do Job |
| `ttlSecondsAfterFinished` | apaga o Job depois de terminar |

| Campo (CronJob) | Efeito |
|---|---|
| `schedule` / `timeZone` | quando e em qual fuso |
| `suspend` | pausa o agendamento |
| `concurrencyPolicy` | `Allow`, `Forbid`, `Replace` |

## Comparação com comandos próximos

| Workload | Termina? | Reinicia? |
|---|---|---|
| Deployment | não | sim, sempre |
| Job | sim | até `backoffLimit` |
| CronJob | cria Jobs no horário | — |

## Antes e depois

No SNO, deixe CronJobs suspensos e dispare manualmente; nunca agende a cada minuto e esqueça.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME      STATUS     COMPLETIONS   DURATION   AGE
ac05-oi   Complete   1/1           6s         20s
```

## Erros comuns

- `AlreadyExists`: Jobs têm nome fixo; use um nome novo por execução.
- `BackoffLimitExceeded`: a tarefa falhou mais vezes do que o permitido (TS-017).

## Ajuda e documentação

```bash
oc create job --help
oc create cronjob --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc delete job <nome>` (apaga os pods) e `oc delete cronjob <nome>`.
