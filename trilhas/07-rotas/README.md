# Trilha 07 — Routes e Ingress

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Publicar aplicações para fora do cluster: Routes HTTP, hostname próprio e o `hosts` do Windows, rotas por caminho,
admissão e conflitos, TLS (edge com certificado padrão e próprio, passthrough, reencrypt conceitual), divisão de
tráfego por pesos, anotações do router, Ingress → Route, a visão do admin e um roteiro de diagnóstico.

> Prefere só os comandos com a explicação? Veja o [guia direto 07](../../guia/07-rotas.md).

## Pré-requisitos

- Trilhas 00–06 (em especial a 06, Services).
- **REQUER PREPARAÇÃO:**
  - na `ocp-admin`, o curinga `*.apps.ocp.example.lab` precisa resolver para `192.168.10.200` (DNS `192.168.10.25`) —
    confira com `getent ahostsv4 teste.apps.ocp.example.lab`;
  - no Windows, o arquivo `hosts` **não aceita curinga**: cada hostname acessado pelo navegador precisa de uma linha;
  - pull de `registry.access.redhat.com/ubi9/httpd-24`.
- `openssl` e `curl` na `ocp-admin` (padrão no RHEL).
- O RTE-013 usa o perfil `admin`, **somente leitura**.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [RTE-001](exercicios/RTE-001.md) | Primeira Route: do navegador ao pod | MUTAÇÃO LOCAL |
| [RTE-002](exercicios/RTE-002.md) | O caminho da requisição: DNS, router e cabeçalho Host | LEITURA |
| [RTE-003](exercicios/RTE-003.md) | Hostname próprio e o arquivo hosts do Windows | MUTAÇÃO LOCAL |
| [RTE-004](exercicios/RTE-004.md) | Rotas por caminho e reescrita | MUTAÇÃO LOCAL |
| [RTE-005](exercicios/RTE-005.md) | Status da Route: admitida, por qual router, com qual host | MUTAÇÃO LOCAL |
| [RTE-006](exercicios/RTE-006.md) | HTTPS com terminação edge e certificado padrão | MUTAÇÃO LOCAL |
| [RTE-007](exercicios/RTE-007.md) | Edge com certificado próprio | MUTAÇÃO LOCAL |
| [RTE-008](exercicios/RTE-008.md) | Passthrough: o TLS vai até o pod | MUTAÇÃO LOCAL |
| [RTE-009](exercicios/RTE-009.md) | Reencrypt: TLS nas duas pontas (conceitual com dry-run) | LEITURA |
| [RTE-010](exercicios/RTE-010.md) | A/B com pesos: dividir o tráfego entre Services | MUTAÇÃO LOCAL |
| [RTE-011](exercicios/RTE-011.md) | Anotações do router: timeout, balanceamento e cookies | MUTAÇÃO LOCAL |
| [RTE-012](exercicios/RTE-012.md) | Ingress do Kubernetes vira Route | MUTAÇÃO LOCAL |
| [RTE-013](exercicios/RTE-013.md) | O Ingress Controller visto pelo admin (somente leitura) | LEITURA |
| [RTE-014](exercicios/RTE-014.md) | Roteiro de diagnóstico de Route | MUTAÇÃO LOCAL |
| [RTE-015](exercicios/RTE-015.md) | Circuito de Routes e encerramento da trilha | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/07-rotas/`](../../solucoes/07-rotas/). Ficha: [`oc-route`](../../catalogo/fichas/oc-route.md).
Cenários: [TS-022](../../cenarios/troubleshooting/TS-022.md) (503 do router), [TS-023](../../cenarios/troubleshooting/TS-023.md)
(HostAlreadyClaimed), [TS-024](../../cenarios/troubleshooting/TS-024.md) (hostname fora do curinga).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 07
scripts/academy show RTE-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac07-rotas` com `web-azul`, `web-verde` e Services | RTE-001 | RTE-015 |
| Routes de teste (`loja`, `cores-*`, `seguro`, `proprio`, `direto`, `ab`, `anot`...) | RTE-001 a RTE-014 | no próprio exercício / RTE-015 |
| Ingress `loja-ing`, `loja-ing2` (e as Routes geradas) | RTE-012 | RTE-012 |
| certificados e chaves **de treino** em `/tmp/ac07` | RTE-006, RTE-007 | RTE-015 |
| linhas `...ac07...` no `hosts` do Windows | RTE-003 | RTE-015 (manual) |

Nenhum exercício altera o Ingress Controller, o certificado padrão do cluster ou o DNS do HomeLab.
