# Trilha 18 — Operadores e manutenção

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Observar a plataforma sem tocar nela: ClusterVersion e atualizações disponíveis, ClusterOperators e suas condições,
a cadeia operador → CR → operand, `managementState` e overrides, OLM (catálogos, pacotes, Subscriptions, CSVs,
InstallPlans), instalação só no papel, CRDs, MachineConfig e o que reinicia o nó, manutenção de nó (conceitual),
planejamento de atualização, backup do etcd, alertas pela API, diagnóstico de operador degradado e o relatório
semanal de saúde.

> Prefere só os comandos com a explicação? Veja o [guia direto 18](../../guia/18-operadores.md).

## Pré-requisitos

- Trilhas 00 (ORI-005 a ORI-008) e 17.
- Perfil **`admin`, somente leitura**, em toda a trilha.
- **Nada é alterado:** sem `oc adm upgrade --to`, sem `drain`/`cordon`/reboot, sem MachineConfig, sem mudar
  `managementState`, sem aprovar InstallPlans. Mudanças aparecem como `--dry-run=server` (OPS-007) ou como plano escrito.
- REQUER PREPARAÇÃO: curinga `*.apps` na `ocp-admin` para o OPS-013 (Routes do monitoramento).

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [OPS-001](exercicios/OPS-001.md) | ClusterVersion: versão, canal, histórico e atualizações disponíveis | LEITURA |
| [OPS-002](exercicios/OPS-002.md) | ClusterOperators: as três condições e as mensagens | LEITURA |
| [OPS-003](exercicios/OPS-003.md) | Do operador ao operand: seguir os relatedObjects | LEITURA |
| [OPS-004](exercicios/OPS-004.md) | managementState e overrides: o que não se deve tocar (leitura) | LEITURA |
| [OPS-005](exercicios/OPS-005.md) | OLM: catálogos e pacotes disponíveis | LEITURA |
| [OPS-006](exercicios/OPS-006.md) | Operadores instalados: Subscription, CSV, InstallPlan e OperatorGroup | LEITURA |
| [OPS-007](exercicios/OPS-007.md) | Instalar um operador: só no papel (dry-run de servidor) | LEITURA |
| [OPS-008](exercicios/OPS-008.md) | CRDs: as APIs que os operadores acrescentam | LEITURA |
| [OPS-009](exercicios/OPS-009.md) | MachineConfig e MachineConfigPool: o que reinicia o nó | LEITURA |
| [OPS-010](exercicios/OPS-010.md) | O que drain, cordon e reboot fariam no SNO (conceitual) | LEITURA |
| [OPS-011](exercicios/OPS-011.md) | Planejar uma atualização (sem atualizar) | LEITURA |
| [OPS-012](exercicios/OPS-012.md) | Backup do etcd: entender e planejar (sem executar) | LEITURA |
| [OPS-013](exercicios/OPS-013.md) | Monitoramento: alertas ativos pela API (leitura) | LEITURA |
| [OPS-014](exercicios/OPS-014.md) | Roteiro de diagnóstico de operador degradado | LEITURA |
| [OPS-015](exercicios/OPS-015.md) | Circuito de operação e o relatório semanal de saúde | LEITURA |

Gabaritos: [`solucoes/18-operadores/`](../../solucoes/18-operadores/). Ficha:
[`oc-operadores-manutencao`](../../catalogo/fichas/oc-operadores-manutencao.md).
Cenários: [TS-055](../../cenarios/troubleshooting/TS-055.md) (operadores após religar o SNO),
[TS-056](../../cenarios/troubleshooting/TS-056.md) (MCP travado),
[TS-057](../../cenarios/troubleshooting/TS-057.md) (InstallPlan esperando aprovação).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-admin
scripts/academy list --trilha 18
scripts/academy show OPS-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto vazio `ac18-ops` (só para o dry-run da Subscription) | OPS-007 | OPS-007 |
| relatórios em `~/relatorios` (fora do repositório) | OPS-015 | quando você quiser |

Nenhum objeto da plataforma é criado, alterado ou apagado nesta trilha.
