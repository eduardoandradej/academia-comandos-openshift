# Ficha: `oc api-resources` e `oc api-versions`

> **Impacto:** LEITURA · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [CON-001](../../trilhas/02-consultas/exercicios/CON-001.md), [CON-002](../../trilhas/02-consultas/exercicios/CON-002.md)

## Quando usar

Para descobrir tipos, nomes curtos, grupos, escopo e verbos antes de escrever um `get` ou um YAML.

## Forma canônica

```bash
oc api-resources --api-group=apps
```

## Sintaxe

```text
oc api-resources [--namespaced=true|false] [--api-group=G] [--verbs=v1,v2] [-o wide|name] [--sort-by=name|kind]
oc api-versions
```

## Exemplos no HomeLab

```bash
oc api-resources --namespaced=false
oc api-resources --api-group=route.openshift.io
oc api-resources -o wide | grep '^deployments '
oc api-versions | grep openshift
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--namespaced` | filtra por escopo |
| `--api-group` | filtra por grupo (`''` = core) |
| `--verbs` | só tipos que aceitam esses verbos |
| `-o wide` | mostra a coluna VERBS |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc explain` | esquema de um tipo |
| `oc get --raw /apis` | mesma informação em JSON cru |

## Antes e depois

Antes de um `oc get` com tipo desconhecido; depois de instalar um operador (novos CRDs).

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME          SHORTNAMES   APIVERSION   NAMESPACED   KIND
deployments   deploy       apps/v1      true         Deployment
```

## Erros comuns

- `the server doesn't have a resource type`: digitação ou CRD ausente.

## Ajuda e documentação

```bash
oc api-resources --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura; nada a desfazer.
