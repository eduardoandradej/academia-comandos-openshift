# Trilha 01 — Navegação e CLI

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Fluência no "esqueleto" de qualquer sessão: versões, ajuda, autocompletar, login/logout em kubeconfig dedicado,
identidade, contextos, projetos, namespace padrão, verbosidade, plugins, `oc` × `kubectl` e diagnóstico de conexão.
Ao final, um circuito de 20 comandos feitos de memória.

## Pré-requisitos

- Trilha 00 concluída, em especial o [ORI-004](../00-orientacao/exercicios/ORI-004.md) (perfis `ac-developer` e `ac-admin`).
- `source scripts/perfis.sh` carregado no terminal.
- CLI-010, CLI-011 e CLI-013 usam o alvo de observação (`manifests/apps-exemplo/observacao-httpd.yaml`):
  **REQUER PREPARAÇÃO** — o cluster precisa baixar `registry.access.redhat.com/ubi9/httpd-24`.

## Exercícios

| ID | Título | Perfil | Impacto |
|---|---|---|---|
| [CLI-001](exercicios/CLI-001.md) | Versões do cliente e do servidor | developer | LEITURA |
| [CLI-002](exercicios/CLI-002.md) | A ajuda como mapa: help, --help e options | local | LEITURA |
| [CLI-003](exercicios/CLI-003.md) | Autocompletar no bash | developer | MUTAÇÃO LOCAL |
| [CLI-004](exercicios/CLI-004.md) | Login e logout com kubeconfig dedicado | developer, admin | MUTAÇÃO LOCAL |
| [CLI-005](exercicios/CLI-005.md) | whoami a fundo, sem revelar segredos | developer | LEITURA |
| [CLI-006](exercicios/CLI-006.md) | Anatomia do kubeconfig sem revelar segredos | developer | LEITURA |
| [CLI-007](exercicios/CLI-007.md) | Projetos: criar, listar e alternar | developer | MUTAÇÃO LOCAL |
| [CLI-008](exercicios/CLI-008.md) | Namespace padrão, -n e precedência | developer | LEITURA |
| [CLI-009](exercicios/CLI-009.md) | Vários kubeconfigs, contextos e --context | developer, admin | MUTAÇÃO LOCAL |
| [CLI-010](exercicios/CLI-010.md) | oc status e --suggest | developer | MUTAÇÃO LOCAL |
| [CLI-011](exercicios/CLI-011.md) | Verbosidade e timeout: ver o que a CLI faz | developer | LEITURA |
| [CLI-012](exercicios/CLI-012.md) | Plugins do oc | developer | MUTAÇÃO LOCAL |
| [CLI-013](exercicios/CLI-013.md) | oc e kubectl: equivalências e diferenças | developer | LEITURA |
| [CLI-014](exercicios/CLI-014.md) | Diagnóstico de conexão: DNS, TLS e porta | developer | LEITURA |
| [CLI-015](exercicios/CLI-015.md) | Circuito 20× da CLI e encerramento | developer | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/01-cli/`](../../solucoes/01-cli/). Fichas usadas: [`oc-version`](../../catalogo/fichas/oc-version.md),
[`oc-whoami`](../../catalogo/fichas/oc-whoami.md), [`oc-login-logout`](../../catalogo/fichas/oc-login-logout.md),
[`oc-config`](../../catalogo/fichas/oc-config.md), [`oc-project`](../../catalogo/fichas/oc-project.md),
[`oc-status`](../../catalogo/fichas/oc-status.md), [`oc-help-completion-plugin`](../../catalogo/fichas/oc-help-completion-plugin.md).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 01
scripts/academy show CLI-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac01-cli` (+ alvo de observação a partir do CLI-010) | CLI-007 | CLI-015 |
| projeto `ac01-cli-b` | CLI-007 | CLI-007 |
| completion em `~/.local/share/bash-completion/completions/` | CLI-003 | permanece (opcional remover) |
| plugins `~/.local/bin/oc-ac-*` | CLI-012 | CLI-012 / CLI-015 |
| contextos renomeados `dev`/`adm` nos seus kubeconfigs | CLI-009 | permanecem (inofensivos) |

O kubeconfig do instalador nunca é alterado; vários exercícios pedem para provar isso com `stat`.
