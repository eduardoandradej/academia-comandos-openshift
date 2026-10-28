# Trilha 11 — Resiliência

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Aplicações que aguentam falhas e mudanças: requests e limits, medição de consumo, CPU estrangulada × memória
morta, readiness, liveness e startup probes, parâmetros e tempo de reação, autocura, desligamento gracioso, rollout
sem indisponibilidade, HPA (até 2 réplicas), decisões do HPA, PodDisruptionBudget e um roteiro de diagnóstico.

> Prefere só os comandos com a explicação? Veja o [guia direto 11](../../guia/11-resiliencia.md).

## Pré-requisitos

- Trilhas 00–06 (em especial 04, 05 e 06).
- **REQUER PREPARAÇÃO:** pull de `registry.access.redhat.com/ubi9/httpd-24`.
- **Metrics API** para RES-002, RES-011 e RES-012 (confira com `oc adm top pods`); sem ela, esses exercícios ficam na leitura das condições.
- **Carga controlada:** laços de CPU só dentro de contêineres com `limits.cpu: 100m`; HPA com no máximo 2 réplicas.
- O RES-013 testa evicção **pela API, pod a pod** — nunca `oc adm drain` no SNO.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [RES-001](exercicios/RES-001.md) | Requests, limits e o que cada um decide | MUTAÇÃO LOCAL |
| [RES-002](exercicios/RES-002.md) | Medir consumo: oc adm top e a Metrics API | LEITURA |
| [RES-003](exercicios/RES-003.md) | CPU estrangulada × memória morta | MUTAÇÃO LOCAL |
| [RES-004](exercicios/RES-004.md) | Readiness probe: tirar do Service quem não está pronto | MUTAÇÃO LOCAL |
| [RES-005](exercicios/RES-005.md) | Liveness probe: reiniciar o que travou | MUTAÇÃO LOCAL |
| [RES-006](exercicios/RES-006.md) | Startup probe: proteger aplicações lentas para iniciar | MUTAÇÃO LOCAL |
| [RES-007](exercicios/RES-007.md) | Parâmetros das probes: calcular o tempo de reação | MUTAÇÃO LOCAL |
| [RES-008](exercicios/RES-008.md) | Autocura: quem recria o quê | MUTAÇÃO LOCAL |
| [RES-009](exercicios/RES-009.md) | Desligamento gracioso: preStop e terminationGracePeriod | MUTAÇÃO LOCAL |
| [RES-010](exercicios/RES-010.md) | Rollout sem indisponibilidade | MUTAÇÃO LOCAL |
| [RES-011](exercicios/RES-011.md) | HPA: escalar por CPU (até 2 réplicas) | MUTAÇÃO LOCAL |
| [RES-012](exercicios/RES-012.md) | Ler as decisões do HPA | MUTAÇÃO LOCAL |
| [RES-013](exercicios/RES-013.md) | PodDisruptionBudget: proteger réplicas em manutenções | MUTAÇÃO LOCAL |
| [RES-014](exercicios/RES-014.md) | Roteiro de diagnóstico de resiliência | MUTAÇÃO LOCAL |
| [RES-015](exercicios/RES-015.md) | Circuito de resiliência e encerramento da trilha | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/11-resiliencia/`](../../solucoes/11-resiliencia/). Ficha:
[`oc-set-probe-autoscale`](../../catalogo/fichas/oc-set-probe-autoscale.md).
Cenários: [TS-034](../../cenarios/troubleshooting/TS-034.md) (liveness agressiva),
[TS-035](../../cenarios/troubleshooting/TS-035.md) (HPA sem alvo),
[TS-036](../../cenarios/troubleshooting/TS-036.md) (PDB bloqueando evicção).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 11
scripts/academy show RES-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac11-resiliencia` com Deployment e Service `ac11-app` | RES-001, RES-004 | RES-015 |
| Deployment `ac11-lento` | RES-006 | RES-006 |
| pods `ac11-quebra`, `ac11-cliente` | RES-008, RES-010 | no próprio exercício |
| HPA `ac11-app` | RES-011 | RES-015 |
| PDB `ac11-pdb` | RES-013 | RES-013 |
| Deployment `ac11-agressivo` | RES-014 | RES-014 |

Nenhum exercício drena, isola ou reinicia o nó, nem altera o monitoramento do cluster.
