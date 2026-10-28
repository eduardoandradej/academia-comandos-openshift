# Trilha 02 — Leitura e inspeção

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Ler o cluster com precisão é metade do diagnóstico. Esta trilha treina descobrir tipos (`api-resources`), ler
esquemas (`explain`), consultar objetos em todos os formatos (`-o wide|name|yaml|json|jsonpath|custom-columns|go-template`),
filtrar por rótulo e campo, processar com `jq`, ordenar, ler eventos, escolher entre `describe` e `get -o yaml`,
acompanhar mudanças (`-w`, `wait`) e falar direto com a API (`get --raw`).

## Pré-requisitos

- Trilhas 00 e 01 (perfis e projetos).
- CON-003 implanta o alvo de observação em `ac02-consultas`: 2 pods httpd pequenos, um Service e um ConfigMap,
  todos rotulados. **REQUER PREPARAÇÃO:** o cluster precisa baixar `registry.access.redhat.com/ubi9/httpd-24`.
  Sem isso, CON-001, CON-002 e a parte de cluster do CON-015 continuam possíveis.
- Recomendado: o perfil `admin` aplicar a baseline de cota ao projeto (como no [ORI-012](../00-orientacao/exercicios/ORI-012.md)).

## Exercícios

| ID | Título | Perfil | Impacto |
|---|---|---|---|
| [CON-001](exercicios/CON-001.md) | api-resources: o inventário de tipos | developer | LEITURA |
| [CON-002](exercicios/CON-002.md) | explain e api-versions: a documentação dentro do cluster | developer | LEITURA |
| [CON-003](exercicios/CON-003.md) | Preparar o alvo de observação | developer | MUTAÇÃO LOCAL |
| [CON-004](exercicios/CON-004.md) | oc get: formatos básicos e vários tipos | developer | LEITURA |
| [CON-005](exercicios/CON-005.md) | Seletores de rótulo | developer | LEITURA |
| [CON-006](exercicios/CON-006.md) | Seletores de campo | developer | LEITURA |
| [CON-007](exercicios/CON-007.md) | YAML e JSON: spec, status e metadata | developer | LEITURA |
| [CON-008](exercicios/CON-008.md) | JSONPath do básico aos filtros | developer | LEITURA |
| [CON-009](exercicios/CON-009.md) | custom-columns: tabelas sob medida | developer | LEITURA |
| [CON-010](exercicios/CON-010.md) | go-template: laços e condições | developer | LEITURA |
| [CON-011](exercicios/CON-011.md) | jq: filtrar, transformar e contar | developer | LEITURA |
| [CON-012](exercicios/CON-012.md) | Ordenar e ler eventos | developer | LEITURA |
| [CON-013](exercicios/CON-013.md) | describe ou get -o yaml? | developer | LEITURA |
| [CON-014](exercicios/CON-014.md) | Acompanhar mudanças: watch e wait | developer | MUTAÇÃO LOCAL |
| [CON-015](exercicios/CON-015.md) | Leitura bruta da API, circuito e encerramento | developer (+admin) | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/02-consultas/`](../../solucoes/02-consultas/). Cenários desta trilha:
[TS-007](../../cenarios/troubleshooting/TS-007.md), [TS-008](../../cenarios/troubleshooting/TS-008.md),
[TS-009](../../cenarios/troubleshooting/TS-009.md).

## Qual formato usar?

| Pergunta | Formato |
|---|---|
| Só quero ver | padrão ou `-o wide` |
| Vou encadear em outro comando | `-o name` |
| Preciso do valor exato | `-o yaml` / `-o json` |
| Um ou poucos campos, sem dependências | `-o jsonpath` |
| Tabela legível sob medida | `-o custom-columns` |
| Condições simples | `-o go-template` |
| Lógica, somas, agrupamentos | `-o json \| jq` |
| O que está acontecendo (eventos) | `oc describe` |

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 02
scripts/academy show CON-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac02-consultas` + alvo de observação | CON-003 | CON-015 |
| Deployment `obs-quebrado` (cenário) | TS-009 | TS-009 |
| arquivos `/tmp/ac-*` | CON-009, CON-010, CON-013 | no próprio exercício / CON-015 |
