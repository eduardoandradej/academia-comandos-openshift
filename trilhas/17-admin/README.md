# Trilha 17 — Administração de recursos

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

O lado do administrador: capacidade do nó (alocável × reservado × uso), quem consome, ResourceQuota completa e suas
recusas, LimitRange e a ordem da admissão, ClusterResourceQuota entre projetos, controles de agendamento (leitura),
PriorityClass baixa, varredura diária do cluster, saúde do plano de controle, logs do nó sem entrar nele, coleta para
suporte e um roteiro de diagnóstico de recursos.

> Prefere só os comandos com a explicação? Veja o [guia direto 17](../../guia/17-admin.md).

## Pré-requisitos

- Trilhas 00 (ORI-008, ORI-012), 04 (QoS), 11 (requests/limits) e 15 (RBAC).
- Perfil **`admin`** (ORI-004) na maior parte da trilha; o `developer` testa as recusas.
- **Limites da Academia:** objetos só em projetos `ac17-*`; objetos de cluster (ClusterResourceQuota, PriorityClass)
  rotulados `academy.openshift.dev/trilha=17` e removidos no ADM-015. **Nunca** rotular, aplicar taint, isolar, drenar
  ou reiniciar o nó; nunca aprovar CSRs; must-gather só planejado.
- Manifestos: [`manifests/admin/`](../../manifests/admin/README.md).
- REQUER PREPARAÇÃO: pull de `registry.access.redhat.com/ubi9/httpd-24`.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [ADM-001](exercicios/ADM-001.md) | Capacidade do nó: o que cabe e o que está reservado | LEITURA |
| [ADM-002](exercicios/ADM-002.md) | Quem reserva e quem consome: ranking por projeto | LEITURA |
| [ADM-003](exercicios/ADM-003.md) | ResourceQuota completa: computação, objetos e escopos | MUTAÇÃO LOCAL |
| [ADM-004](exercicios/ADM-004.md) | Quota em ação: recusas e a exigência de requests | MUTAÇÃO LOCAL |
| [ADM-005](exercicios/ADM-005.md) | LimitRange: padrões, mínimos, máximos e razão | MUTAÇÃO LOCAL |
| [ADM-006](exercicios/ADM-006.md) | Quota e LimitRange juntos: a ordem da admissão | MUTAÇÃO LOCAL |
| [ADM-007](exercicios/ADM-007.md) | ClusterResourceQuota: uma cota para vários projetos | MUTAÇÃO DE CLUSTER (rotulada) |
| [ADM-008](exercicios/ADM-008.md) | Onde os pods podem rodar: node selector, taints e o agendador (leitura) | LEITURA |
| [ADM-009](exercicios/ADM-009.md) | PriorityClass: prioridade baixa para o treino | MUTAÇÃO DE CLUSTER (rotulada) |
| [ADM-010](exercicios/ADM-010.md) | Varredura do cluster: pods com problema e eventos de aviso | LEITURA |
| [ADM-011](exercicios/ADM-011.md) | Saúde do plano de controle por leitura | LEITURA |
| [ADM-012](exercicios/ADM-012.md) | Logs do nó sem entrar no nó | LEITURA |
| [ADM-013](exercicios/ADM-013.md) | Coleta para suporte: oc adm inspect (pequeno) e must-gather (planejado) | LEITURA |
| [ADM-014](exercicios/ADM-014.md) | Roteiro de diagnóstico de recursos | MUTAÇÃO LOCAL |
| [ADM-015](exercicios/ADM-015.md) | Circuito de administração e encerramento da trilha | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/17-admin/`](../../solucoes/17-admin/). Ficha:
[`oc-quota-limitrange`](../../catalogo/fichas/oc-quota-limitrange.md).
Cenários: [TS-052](../../cenarios/troubleshooting/TS-052.md) (`must specify`),
[TS-053](../../cenarios/troubleshooting/TS-053.md) (ClusterResourceQuota compartilhada),
[TS-054](../../cenarios/troubleshooting/TS-054.md) (`Insufficient cpu` com o nó ocioso).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-admin
scripts/academy list --trilha 17
scripts/academy show ADM-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac17-cotas` com quotas e LimitRange | ADM-003, ADM-005 | ADM-015 |
| projetos `ac17-equipe-a/b` | ADM-007 | ADM-007 |
| ClusterResourceQuota `ac17-equipe` | ADM-007 | ADM-015 |
| PriorityClass `ac17-baixa` (valor -10, sem preempção) | ADM-009 | ADM-015 |
| coleta em `/tmp/ac17-coleta` | ADM-013 | ADM-013 |
