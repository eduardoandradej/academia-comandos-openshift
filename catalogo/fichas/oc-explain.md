# Ficha: `oc explain`

> **Impacto:** LEITURA · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [CON-002](../../trilhas/02-consultas/exercicios/CON-002.md), [ORI-013](../../trilhas/00-orientacao/exercicios/ORI-013.md)

## Quando usar

Para ler a documentação de qualquer campo de qualquer tipo, direto da API.

## Forma canônica

```bash
oc explain deployment.spec.replicas
```

## Sintaxe

```text
oc explain TIPO[.CAMPO...] [--recursive] [--api-version=G/V]
```

## Exemplos no HomeLab

```bash
oc explain pod.spec.containers
oc explain deployment.spec.strategy.rollingUpdate.maxSurge
oc explain route.spec.tls
oc explain pod.spec --recursive | less
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--recursive` | árvore de campos, sem descrições |
| `--api-version` | escolhe a versão do tipo |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc get -o yaml` | valores atuais, não a documentação |
| `oc create ... --dry-run=client -o yaml` | um exemplo pronto do objeto |

## Antes e depois

Antes de escrever ou editar YAML.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
GROUP:      apps
KIND:       Deployment
VERSION:    v1

FIELD: replicas <integer>

DESCRIPTION:
    Number of desired pods. ...
```

## Erros comuns

- `field "x" does not exist`: nome/caixa errados ou nível errado; listas não usam índice.

## Ajuda e documentação

```bash
oc explain --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura; nada a desfazer.
