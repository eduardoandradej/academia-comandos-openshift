# Trilha 05 — Deployments e workloads

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Aplicações gerenciadas: Deployments e seus ReplicaSets, escala, rollouts (disparar, acompanhar, registrar, desfazer,
reiniciar, pausar), `oc set`, estratégias, `oc new-app`, Jobs, CronJobs, DaemonSets e o ciclo declarativo.

> Prefere só os comandos com a explicação? Veja o [guia direto 05](../../guia/05-deployments.md).

## Pré-requisitos

- Trilhas 00–04.
- **REQUER PREPARAÇÃO:** pull de `registry.access.redhat.com/ubi9/httpd-24` (normalmente já em cache). As "versões" dos
  rollouts são feitas com variáveis de ambiente e com o digest da mesma imagem — nada novo é baixado.
- Recomendado: baseline de quota em `ac05-deploy` ([ORI-012](../00-orientacao/exercicios/ORI-012.md)). O cenário TS-018 **exige** a baseline.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [DEP-001](exercicios/DEP-001.md) | Criar um Deployment e ver a cadeia Deployment → ReplicaSet → Pods | MUTAÇÃO LOCAL |
| [DEP-002](exercicios/DEP-002.md) | Escalar e autocura | MUTAÇÃO LOCAL |
| [DEP-003](exercicios/DEP-003.md) | Rollout: disparar, acompanhar e registrar o motivo | MUTAÇÃO LOCAL |
| [DEP-004](exercicios/DEP-004.md) | Voltar no tempo: rollout undo e revisões | MUTAÇÃO LOCAL |
| [DEP-005](exercicios/DEP-005.md) | restart, pause e resume | MUTAÇÃO LOCAL |
| [DEP-006](exercicios/DEP-006.md) | oc set: imagem, recursos e variáveis | MUTAÇÃO LOCAL |
| [DEP-007](exercicios/DEP-007.md) | Estratégias: RollingUpdate e Recreate | MUTAÇÃO LOCAL |
| [DEP-008](exercicios/DEP-008.md) | ReplicaSets: quem manda em quem | MUTAÇÃO LOCAL |
| [DEP-009](exercicios/DEP-009.md) | oc new-app a partir de uma imagem | MUTAÇÃO LOCAL |
| [DEP-010](exercicios/DEP-010.md) | Jobs: tarefas que terminam | MUTAÇÃO LOCAL |
| [DEP-011](exercicios/DEP-011.md) | CronJobs: agendar sem sobrecarregar | MUTAÇÃO LOCAL |
| [DEP-012](exercicios/DEP-012.md) | DaemonSet: um pod por nó | MUTAÇÃO LOCAL (+ leitura admin) |
| [DEP-013](exercicios/DEP-013.md) | Deployment declarativo: gerar, editar, comparar e aplicar | MUTAÇÃO LOCAL |
| [DEP-014](exercicios/DEP-014.md) | Ler o estado de um Deployment: condições e contadores | MUTAÇÃO LOCAL |
| [DEP-015](exercicios/DEP-015.md) | Circuito de workloads e encerramento da trilha | MUTAÇÃO LOCAL |

Perfil `developer` (DEP-012 também lê DaemonSets da plataforma com `admin`). Gabaritos: [`solucoes/05-deployments/`](../../solucoes/05-deployments/).
Fichas: [`oc-create-deployment-scale`](../../catalogo/fichas/oc-create-deployment-scale.md), [`oc-rollout`](../../catalogo/fichas/oc-rollout.md),
[`oc-set`](../../catalogo/fichas/oc-set.md), [`oc-create-job-cronjob`](../../catalogo/fichas/oc-create-job-cronjob.md).
Cenários: [TS-016](../../cenarios/troubleshooting/TS-016.md) (rollout travado), [TS-017](../../cenarios/troubleshooting/TS-017.md)
(Job falho), [TS-018](../../cenarios/troubleshooting/TS-018.md) (quota).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 05
scripts/academy show DEP-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac05-deploy` | DEP-001 | DEP-015 |
| Deployment `ac05-web` (2 réplicas, no máximo 3 pods durante rollouts) | DEP-001 | DEP-015 |
| `ac05-app` (new-app), Jobs, CronJob suspenso, DaemonSet `ac05-ds` | DEP-009 a DEP-012 | no próprio exercício |
| arquivos `/tmp/ac05-*` | DEP-005, DEP-013 | DEP-015 |

Nenhum CronJob fica ativo e nenhum Deployment fica pausado ao fim da trilha.
