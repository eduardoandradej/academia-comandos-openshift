# Ficha: `oc get`

> **Impacto:** LEITURA · **Perfil mínimo:** developer (no próprio projeto) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [CON-004](../../trilhas/02-consultas/exercicios/CON-004.md), [CON-005](../../trilhas/02-consultas/exercicios/CON-005.md), [CON-006](../../trilhas/02-consultas/exercicios/CON-006.md), [CON-007](../../trilhas/02-consultas/exercicios/CON-007.md), [CON-008](../../trilhas/02-consultas/exercicios/CON-008.md), [CON-009](../../trilhas/02-consultas/exercicios/CON-009.md), [CON-010](../../trilhas/02-consultas/exercicios/CON-010.md)

## Quando usar

O comando mais usado: listar e ler objetos em vários formatos, com filtros de rótulo e campo.

## Forma canônica

```bash
oc get pods -n ac02-consultas
```

## Sintaxe

```text
oc get TIPO[,TIPO] [NOME...] [-n NS | -A] [-l SELETOR] [--field-selector=CAMPO=VALOR]
       [-o wide|name|yaml|json|jsonpath=...|custom-columns=...|go-template=...]
       [--sort-by=CAMINHO] [-w] [--show-labels] [-L CHAVE] [--no-headers] [--ignore-not-found]
```

## Exemplos no HomeLab

```bash
oc get pods -n ac02-consultas -o wide
oc get deploy,svc,cm -n ac02-consultas -l academy.openshift.dev/managed-by=academia
oc get pods -n ac02-consultas --field-selector=status.phase=Running
oc get pods -n ac02-consultas -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
oc get pods -n ac02-consultas -o custom-columns=NOME:.metadata.name,IP:.status.podIP
oc get events -n ac02-consultas --sort-by=.metadata.creationTimestamp
```

## Flags principais

| Flag | Efeito |
|---|---|
| `-o wide` / `name` / `yaml` / `json` | formatos |
| `-o jsonpath=` / `custom-columns=` / `go-template=` | formatos programáveis |
| `-l` | seletor de rótulo |
| `--field-selector` | seletor de campo (limitado por tipo) |
| `-A` | todos os namespaces (permissão de cluster) |
| `-w` | acompanha mudanças |
| `--sort-by` | ordena no cliente |
| `--show-labels` / `-L` | rótulos |
| `--ignore-not-found` | não falha se ausente |
| `--show-managed-fields` | inclui `managedFields` no YAML/JSON |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc describe` | humano, com eventos e dados agregados |
| `oc explain` | documentação do esquema |
| `oc get --raw` | JSON cru de qualquer caminho da API |

## Antes e depois

Antes de mutar: `oc get` do alvo. Depois: `oc get` de novo para provar o estado.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME                       READY   STATUS    RESTARTS   AGE
obs-web-xxxxxxxxxx-aaaaa   1/1     Running   0          5m
obs-web-xxxxxxxxxx-bbbbb   1/1     Running   0          5m
```

## Erros comuns

- `No resources found in X namespace.`: namespace errado ou vazio (não é erro).
- `Forbidden ... at the cluster scope`: `-A` sem permissão.
- `name cannot be provided when a selector is specified`: nome e `-l` juntos.
- jsonpath vazio sem erro: caminho/caixa errados.

## Ajuda e documentação

```bash
oc get --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura; nada a desfazer.
