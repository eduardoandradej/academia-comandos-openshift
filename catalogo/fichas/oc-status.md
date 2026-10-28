# Ficha: `oc status`

> **Impacto:** LEITURA · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [CLI-010](../../trilhas/01-cli/exercicios/CLI-010.md)

## Quando usar

Primeira olhada em um projeto: Services, Deployments, pods e Routes e como se ligam.

## Forma canônica

```bash
oc status -n ac01-cli
```

## Sintaxe

```text
oc status [-n NS] [--suggest]
```

## Exemplos no HomeLab

```bash
oc status
oc status -n ac01-cli
oc status --suggest -n ac01-cli
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--suggest` | acrescenta recomendações |
| `-n` | outro projeto |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc get all` | lista objetos sem relacioná-los |
| `oc describe` | detalha um objeto |

## Antes e depois

Depois de implantar algo: `oc status` confirma as ligações Service → Deployment.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
In project Academia 01 - CLI (ac01-cli) on server https://api.ocp.example.lab:6443

svc/obs-web - 172.30.x.x:8080
  deployment/obs-web deploys registry.access.redhat.com/ubi9/httpd-24:latest
    deployment #1 running for N minutes - 2 pods
```

## Erros comuns

- Projeto vazio: a saída só informa que não há nada a mostrar (não é erro).

## Ajuda e documentação

```bash
oc status --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura; nada a desfazer.
