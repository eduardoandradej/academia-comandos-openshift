# Ficha: `oc get events`

> **Impacto:** LEITURA · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [CON-006](../../trilhas/02-consultas/exercicios/CON-006.md), [CON-012](../../trilhas/02-consultas/exercicios/CON-012.md)

## Quando usar

Ver a linha do tempo do namespace: agendamento, pull de imagem, início de contêiner, falhas de probe, escala.

## Forma canônica

```bash
oc get events -n ac02-consultas --sort-by=.metadata.creationTimestamp
```

## Sintaxe

```text
oc get events [-n NS] [--field-selector type=Warning,reason=X,involvedObject.name=Y] [--sort-by=...] [-w]
```

## Exemplos no HomeLab

```bash
oc get events -n ac02-consultas --sort-by=.metadata.creationTimestamp | tail
oc get events -n ac02-consultas --field-selector type=Warning
oc get events -n ac02-consultas --field-selector involvedObject.kind=Pod
oc get events -n ac02-consultas -w --watch-only
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--field-selector type=Warning` | só alertas |
| `--sort-by=.metadata.creationTimestamp` | ordem cronológica confiável |
| `-w --watch-only` | só novos eventos |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc describe <obj>` | eventos de um objeto |
| `oc logs` | saída do processo, não do Kubernetes |

## Antes e depois

Depois de aplicar algo ou ao investigar um sintoma.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
LAST SEEN   TYPE     REASON      OBJECT                         MESSAGE
2m          Normal   Scheduled   pod/obs-web-xxxxxxxxxx-aaaaa   Successfully assigned ac02-consultas/...
2m          Normal   Pulled      pod/obs-web-xxxxxxxxxx-aaaaa   Container image ... already present on machine
```

## Erros comuns

- `No resources found`: eventos expiram; não é erro.

## Ajuda e documentação

```bash
oc get events --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura; nada a desfazer.
