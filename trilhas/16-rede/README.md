# Trilha 16 — Rede e isolamento

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Quem fala com quem: a rede do cluster (leitura), um laboratório com dois projetos, negação de entrada, liberação do
próprio projeto, de um cliente de outro projeto (e a armadilha AND × OR), portas, o router depois do isolamento,
negação de saída sem quebrar o DNS, saída seletiva, quais políticas valem para um pod, políticas do admin (leitura),
TLS visto de fora (SNI, cadeia, validade), certificados de serviço e um roteiro de conectividade.

> Prefere só os comandos com a explicação? Veja o [guia direto 16](../../guia/16-rede.md).

## Pré-requisitos

- Trilhas 06 (Services, teste por `/dev/tcp`) e 07 (Routes).
- **REQUER PREPARAÇÃO:** pull de `registry.access.redhat.com/ubi9/httpd-24`; curinga `*.apps` na `ocp-admin` (NET-007).
- `openssl` e `curl` na `ocp-admin`.
- NET-001 e NET-011 usam o perfil `admin`, **somente leitura**. Nenhum exercício altera a rede do cluster, cria
  AdminNetworkPolicy ou EgressFirewall (o NET-011 só valida um EgressFirewall com `--dry-run=server`).
- Políticas de treino: [`manifests/networkpolicies/`](../../manifests/networkpolicies/README.md) — sempre com `-n`.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [NET-001](exercicios/NET-001.md) | A rede do cluster vista pelo admin (somente leitura) | LEITURA |
| [NET-002](exercicios/NET-002.md) | Laboratório de dois projetos: tudo aberto por padrão | MUTAÇÃO LOCAL |
| [NET-003](exercicios/NET-003.md) | Negar toda a entrada (default deny) | MUTAÇÃO LOCAL |
| [NET-004](exercicios/NET-004.md) | Liberar o próprio projeto | MUTAÇÃO LOCAL |
| [NET-005](exercicios/NET-005.md) | Liberar um cliente de outro projeto (e o AND × OR) | MUTAÇÃO LOCAL |
| [NET-006](exercicios/NET-006.md) | Portas, nomes de porta e protocolos | MUTAÇÃO LOCAL |
| [NET-007](exercicios/NET-007.md) | Routes depois do isolamento: liberar o router | MUTAÇÃO LOCAL |
| [NET-008](exercicios/NET-008.md) | Negar a saída sem quebrar o DNS | MUTAÇÃO LOCAL |
| [NET-009](exercicios/NET-009.md) | Saída só para quem precisa | MUTAÇÃO LOCAL |
| [NET-010](exercicios/NET-010.md) | Quais políticas valem para este pod? | LEITURA |
| [NET-011](exercicios/NET-011.md) | Políticas do administrador e EgressFirewall (somente leitura) | LEITURA |
| [NET-012](exercicios/NET-012.md) | Inspecionar TLS de fora: SNI, cadeia e validade | LEITURA |
| [NET-013](exercicios/NET-013.md) | Certificados de serviço: TLS dentro do cluster | MUTAÇÃO LOCAL |
| [NET-014](exercicios/NET-014.md) | Roteiro de diagnóstico de conectividade | MUTAÇÃO LOCAL |
| [NET-015](exercicios/NET-015.md) | Circuito de rede e encerramento da trilha | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/16-rede/`](../../solucoes/16-rede/). Ficha: [`oc-networkpolicy`](../../catalogo/fichas/oc-networkpolicy.md).
Cenários: [TS-049](../../cenarios/troubleshooting/TS-049.md) (Route caiu após isolar),
[TS-050](../../cenarios/troubleshooting/TS-050.md) (DNS bloqueado pela saída),
[TS-051](../../cenarios/troubleshooting/TS-051.md) (OR escondido no `from`).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 16
scripts/academy show NET-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac16-rede` com `web-azul`, `web-verde`, Services e o cliente `ac16-local` | NET-002 | NET-015 |
| projeto `ac16-vizinho` com `ac16-cliente` e `ac16-intruso` | NET-002 | NET-015 |
| NetworkPolicies `ac16-*` | NET-003 a NET-009 | NET-015 (por rótulo) |
| Secret `web-verde-tls` e ConfigMap `ac16-ca` | NET-013 | NET-013 |
