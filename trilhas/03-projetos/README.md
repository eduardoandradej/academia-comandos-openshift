# Trilha 03 — Projetos e metadados

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Metadados são a "cola" do Kubernetes: rótulos selecionam, anotações descrevem e configuram, `ownerReferences`
organizam quem apaga quem, finalizers controlam a exclusão e `generation`/`resourceVersion` contam a história de cada
objeto. Esta trilha treina ler e manipular tudo isso com segurança, em projetos de laboratório.

## Pré-requisitos

- Trilhas 00–02 (perfis, projetos, consultas).
- PRJ-008 em diante usam o alvo de observação: **REQUER PREPARAÇÃO** — pull de `registry.access.redhat.com/ubi9/httpd-24`.
- PRJ-002, PRJ-007, PRJ-014 e parte do PRJ-015 usam o perfil `admin`.
- Recomendado: baseline de quota em `ac03-projetos` ([ORI-012](../00-orientacao/exercicios/ORI-012.md)).

## Exercícios

| ID | Título | Perfil | Impacto |
|---|---|---|---|
| [PRJ-001](exercicios/PRJ-001.md) | Project e Namespace: o mesmo objeto, duas visões | developer, admin | LEITURA |
| [PRJ-002](exercicios/PRJ-002.md) | Criar projetos e namespaces com metadados completos | developer, admin | MUTAÇÃO LOCAL |
| [PRJ-003](exercicios/PRJ-003.md) | Rótulos: adicionar, sobrescrever, listar e remover | developer | MUTAÇÃO LOCAL |
| [PRJ-004](exercicios/PRJ-004.md) | Rótulos em lote por seletor | developer | MUTAÇÃO LOCAL |
| [PRJ-005](exercicios/PRJ-005.md) | Anotações: metadados que não selecionam | developer | MUTAÇÃO LOCAL |
| [PRJ-006](exercicios/PRJ-006.md) | Rótulos recomendados app.kubernetes.io/* | developer | MUTAÇÃO LOCAL |
| [PRJ-007](exercicios/PRJ-007.md) | Metadados que o OpenShift coloca nos namespaces | admin | LEITURA |
| [PRJ-008](exercicios/PRJ-008.md) | Seletores que ligam objetos: Service, Deployment e pods | developer | MUTAÇÃO LOCAL |
| [PRJ-009](exercicios/PRJ-009.md) | ownerReferences e coleta de lixo | developer | MUTAÇÃO LOCAL |
| [PRJ-010](exercicios/PRJ-010.md) | Finalizers e exclusão em duas fases (somente leitura) | developer, admin | MUTAÇÃO LOCAL (rascunho) |
| [PRJ-011](exercicios/PRJ-011.md) | uid, resourceVersion, generation e observedGeneration | developer | MUTAÇÃO LOCAL |
| [PRJ-012](exercicios/PRJ-012.md) | Rótulos imperativos versus manifesto declarativo | developer | MUTAÇÃO LOCAL |
| [PRJ-013](exercicios/PRJ-013.md) | Inventário de uma aplicação por rótulo | developer | LEITURA |
| [PRJ-014](exercicios/PRJ-014.md) | Metadados de projeto como admin: nós, descrição e rótulos | admin | MUTAÇÃO LOCAL |
| [PRJ-015](exercicios/PRJ-015.md) | Circuito de metadados e encerramento da trilha | developer, admin | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/03-projetos/`](../../solucoes/03-projetos/). Ficha principal:
[`oc-label-annotate`](../../catalogo/fichas/oc-label-annotate.md). Cenários:
[TS-010](../../cenarios/troubleshooting/TS-010.md), [TS-011](../../cenarios/troubleshooting/TS-011.md),
[TS-012](../../cenarios/troubleshooting/TS-012.md).

## Mapa rápido

| Quero... | Use |
|---|---|
| agrupar e selecionar | rótulo (`oc label`, `-l`) |
| descrever ou configurar | anotação (`oc annotate`) |
| saber quem apaga quem | `metadata.ownerReferences` |
| entender uma exclusão lenta | `deletionTimestamp`, finalizers, condições do namespace |
| saber se o controlador já reagiu | `generation` × `status.observedGeneration` |
| inventário real de uma app | `oc api-resources --verbs=list` + seletor |

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 03
scripts/academy show PRJ-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac03-projetos` (+ alvo de observação a partir do PRJ-008) | PRJ-002 | PRJ-015 |
| namespace `ac03-extra` (admin, rotulado) | PRJ-002 | PRJ-015 (perfil admin) |
| projetos `ac03-rascunho`, `ac03-finalizador`, `ac03-terminacao` | PRJ-002, PRJ-010, TS-011 | no próprio exercício/cenário |
| ConfigMaps e Services `ac03-*`/`loja-*` | PRJ-003 a PRJ-012 | no próprio exercício / PRJ-015 |
| arquivos `/tmp/ac03-decl.yaml`, `/tmp/inventario.sh` | PRJ-012, PRJ-013 | PRJ-015 |

Nenhum exercício altera anotações operacionais (`openshift.io/node-selector`, `openshift.io/sa.scc.*`), rótulos de
Pod Security ou finalizers.
