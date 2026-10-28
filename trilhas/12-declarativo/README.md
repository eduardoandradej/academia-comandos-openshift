# Trilha 12 — Manifestos declarativos

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Gerenciar recursos por arquivos: gerar manifestos, validar no cliente e no servidor, `create` × `apply`, `oc diff`
como portão, merge de três vias, server-side apply e conflitos, `replace`, os três tipos de `patch`, edição local
(`--local`), exportação limpa, diretórios e ordem, prune com rede de proteção, delete declarativo e as cinco recusas
clássicas.

> Prefere só os comandos com a explicação? Veja o [guia direto 12](../../guia/12-declarativo.md).

## Pré-requisitos

- Trilhas 00–08 (em especial PRJ-012, DEP-013 e CFG-013, que apresentaram `apply`/`diff`).
- **REQUER PREPARAÇÃO:** pull de `registry.access.redhat.com/ubi9/httpd-24`; curinga `*.apps` na `ocp-admin` (Route do DCL-003).
- `jq` e `python3` na `ocp-admin` (padrão no RHEL).
- Arquivo de trabalho: `/tmp/ac12/app.yaml`, cópia de
  [`manifests/apps-exemplo/declarativo-app.yaml`](../../manifests/apps-exemplo/declarativo-app.yaml). Nunca edite o original.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [DCL-001](exercicios/DCL-001.md) | Gerar manifestos sem escrever YAML do zero | LEITURA |
| [DCL-002](exercicios/DCL-002.md) | Validar antes de aplicar: client, server e strict | LEITURA |
| [DCL-003](exercicios/DCL-003.md) | create × apply: criar uma vez ou declarar sempre | MUTAÇÃO LOCAL |
| [DCL-004](exercicios/DCL-004.md) | oc diff: ver a mudança antes de fazê-la | LEITURA |
| [DCL-005](exercicios/DCL-005.md) | Merge de três vias: o que o apply preserva e o que apaga | MUTAÇÃO LOCAL |
| [DCL-006](exercicios/DCL-006.md) | Server-side apply: donos de campos e conflitos | MUTAÇÃO LOCAL |
| [DCL-007](exercicios/DCL-007.md) | replace e replace --force: substituir inteiro | MUTAÇÃO LOCAL |
| [DCL-008](exercicios/DCL-008.md) | Três tipos de patch: strategic, merge e json | MUTAÇÃO LOCAL |
| [DCL-009](exercicios/DCL-009.md) | Editar arquivos sem cluster: --local e patch local | LEITURA |
| [DCL-010](exercicios/DCL-010.md) | Exportar um objeto vivo para um manifesto limpo | LEITURA |
| [DCL-011](exercicios/DCL-011.md) | Diretórios, ordem e dependências | MUTAÇÃO LOCAL |
| [DCL-012](exercicios/DCL-012.md) | Prune: apagar o que saiu do manifesto (com rede de proteção) | MUTAÇÃO LOCAL |
| [DCL-013](exercicios/DCL-013.md) | Delete declarativo e o ciclo completo | MUTAÇÃO LOCAL |
| [DCL-014](exercicios/DCL-014.md) | Roteiro de diagnóstico declarativo | MUTAÇÃO LOCAL |
| [DCL-015](exercicios/DCL-015.md) | Circuito declarativo e encerramento da trilha | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/12-declarativo/`](../../solucoes/12-declarativo/). Ficha:
[`oc-apply-patch-diff`](../../catalogo/fichas/oc-apply-patch-diff.md).
Cenários: [TS-037](../../cenarios/troubleshooting/TS-037.md) (seletor imutável),
[TS-038](../../cenarios/troubleshooting/TS-038.md) (apply desfaz a escala),
[TS-039](../../cenarios/troubleshooting/TS-039.md) (conflito de server-side apply).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 12
scripts/academy show DCL-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac12-declarativo` com ConfigMap, Deployment, Service e Route `ac12-*` | DCL-001, DCL-003 | DCL-015 |
| ConfigMaps `ac12-ssa`, `ac12-flags` | DCL-006, TS-039 | no próprio exercício |
| `ac12-manual` e projeto `ac12-rascunho` | DCL-010 | DCL-010 / DCL-015 |
| arquivos em `/tmp/ac12` | DCL-001 em diante | DCL-015 |

O prune (DCL-012) é sempre restrito a `-n ac12-declarativo`, `-l app=ac12-web`, lista de tipos e dry-run antes.
