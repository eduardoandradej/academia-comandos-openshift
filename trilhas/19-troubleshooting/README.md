# Trilha 19 — Troubleshooting transversal

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Juntar tudo: um método único (os sete andares), uma triagem de 60 segundos, dez casos com **mais de um defeito**
cada — imagem e seletor, configuração e liveness, readiness e `targetPort`, agendamento, RBAC, NetworkPolicy, rollout
sem histórico, CronJob, OOM e despejo, Kustomize —, linha do tempo de incidente, relatório pós-incidente e um
circuito de casos sorteados.

> Prefere só os comandos com a explicação? Veja o [guia direto 19](../../guia/19-troubleshooting.md).

## Pré-requisitos

- Trilhas 04 a 16 (cada caso usa o diagnóstico de uma ou mais delas).
- Perfil `developer`. Projetos `ac19-casos` e `ac19-rede` (caso 06).
- **REQUER PREPARAÇÃO:** pull de `registry.access.redhat.com/ubi9/httpd-24`; curinga `*.apps` (casos 03 e 06).
- Casos em [`manifests/casos/`](../../manifests/casos/README.md): aplique **sem ler** o manifesto — o arquivo diz só o sintoma.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [DIA-001](exercicios/DIA-001.md) | O método dos sete andares | MUTAÇÃO LOCAL |
| [DIA-002](exercicios/DIA-002.md) | Triagem de um projeto em 60 segundos | LEITURA |
| [DIA-003](exercicios/DIA-003.md) | Caso 01: a vitrine que não responde | MUTAÇÃO LOCAL |
| [DIA-004](exercicios/DIA-004.md) | Caso 02: o catálogo que nunca fica estável | MUTAÇÃO LOCAL |
| [DIA-005](exercicios/DIA-005.md) | Caso 03: a Route que responde 503 | MUTAÇÃO LOCAL |
| [DIA-006](exercicios/DIA-006.md) | Caso 04: o relatório preso em Pending | MUTAÇÃO LOCAL |
| [DIA-007](exercicios/DIA-007.md) | Caso 05: o robô de escala recebe Forbidden | MUTAÇÃO LOCAL |
| [DIA-008](exercicios/DIA-008.md) | Caso 06: depois do endurecimento, nada fala com nada | MUTAÇÃO LOCAL |
| [DIA-009](exercicios/DIA-009.md) | Caso 07: o rollout que não termina e o undo que não volta | MUTAÇÃO LOCAL |
| [DIA-010](exercicios/DIA-010.md) | Caso 08: o fechamento diário que não roda | MUTAÇÃO LOCAL |
| [DIA-011](exercicios/DIA-011.md) | Caso 09: aplicações que reiniciam ou somem | MUTAÇÃO LOCAL |
| [DIA-012](exercicios/DIA-012.md) | Caso 10: o overlay de produção que não entrega o que promete | LEITURA |
| [DIA-013](exercicios/DIA-013.md) | Linha do tempo de um incidente | MUTAÇÃO LOCAL |
| [DIA-014](exercicios/DIA-014.md) | Relatório pós-incidente sem culpados | LEITURA |
| [DIA-015](exercicios/DIA-015.md) | Circuito cego: casos sorteados | MUTAÇÃO LOCAL |

Gabaritos (com os defeitos de cada caso): [`solucoes/19-troubleshooting/`](../../solucoes/19-troubleshooting/). Ficha:
[`oc-diagnostico`](../../catalogo/fichas/oc-diagnostico.md).
Cenários: [TS-058](../../cenarios/troubleshooting/TS-058.md) (Service com duas versões),
[TS-059](../../cenarios/troubleshooting/TS-059.md) (porta nomeada),
[TS-060](../../cenarios/troubleshooting/TS-060.md) (endpoint intruso).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
oc new-project ac19-casos
scripts/academy show DIA-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac19-casos` e pod cliente `ac19-cli` | DIA-001, DIA-003 | DIA-015 |
| objetos de cada caso (rótulo `academy.openshift.dev/caso`) | DIA-003 a DIA-011 | no próprio exercício |
| projeto `ac19-rede` | DIA-008 | DIA-008 / DIA-015 |
| cópias e relatórios em `/tmp/ac19` e `~/relatorios` | DIA-012 a DIA-015 | DIA-015 (o que for de `/tmp`) |
