# Ficha: `jq` (com saídas JSON do `oc`)

> **Impacto:** LEITURA (local) · **Perfil mínimo:** nenhum · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [CON-011](../../trilhas/02-consultas/exercicios/CON-011.md), [ORI-003](../../trilhas/00-orientacao/exercicios/ORI-003.md), [ORI-007](../../trilhas/00-orientacao/exercicios/ORI-007.md)

## Quando usar

Filtrar, transformar e contar saídas `-o json` quando jsonpath não basta (somas, agrupamentos, condições complexas).

## Forma canônica

```bash
oc get pods -n ac02-consultas -o json | jq -r '.items[].metadata.name'
```

## Sintaxe

```text
jq [-r] [-c] [-e] [--arg nome valor] 'FILTRO' [arquivo]
```

## Exemplos no HomeLab

```bash
oc get pods -n ac02-consultas -o json | jq '.items | length'
oc get pods -n ac02-consultas -o json | jq -r '.items[] | select(.status.phase=="Running") | .metadata.name'
oc get co -o json | jq -r '.items[] | select(any(.status.conditions[]; .type=="Degraded" and .status=="True")) | .metadata.name'
oc get deploy obs-web -n ac02-consultas -o json | jq '.metadata.labels["academy.openshift.dev/trilha"]'
```

## Flags principais

| Flag | Efeito |
|---|---|
| `-r` | texto cru (sem aspas) |
| `-c` | uma linha por resultado |
| `-e` | código de saída conforme o último valor |
| `--arg` | passa variável do shell |

## Comparação com comandos próximos

| Ferramenta | Quando |
|---|---|
| jsonpath | extração simples, sem dependência |
| custom-columns | tabela legível |
| go-template | condições simples sem `jq` |
| jq | lógica, somas, agrupamentos |

## Antes e depois

Use `jq 'keys'` antes de navegar em um objeto desconhecido.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
2
obs-web-xxxxxxxxxx-aaaaa
obs-web-xxxxxxxxxx-bbbbb
```

## Erros comuns

- `Cannot index array with "x"`: faltou `[]` para iterar.
- `Cannot iterate over null`: campo inexistente.

## Ajuda e documentação

```bash
jq --help
man jq
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura local; nada a desfazer.
