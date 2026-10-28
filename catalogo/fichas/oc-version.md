# Ficha: `oc version`

> **Impacto:** LEITURA · **Perfil mínimo:** nenhum (cliente) / developer (servidor) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [ORI-001](../../trilhas/00-orientacao/exercicios/ORI-001.md), [CLI-001](../../trilhas/01-cli/exercicios/CLI-001.md)

## Quando usar

Para saber a versão do cliente (`--client`, sem contatar a API) e a do servidor; primeiro passo para separar problema de cliente de problema de cluster.

## Forma canônica

```bash
oc version --client
```

## Sintaxe

```text
oc version [--client] [-o yaml|json]
```

## Exemplos no HomeLab

```bash
oc version --client
oc version
oc version -o json | jq -r .serverVersion.gitVersion
oc version --client -o json | jq -r '.releaseClientVersion // .clientVersion.gitVersion'
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--client` | só o cliente; não contata a API |
| `-o yaml` / `-o json` | saída estruturada |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `kubectl version` | mostra só versões Kubernetes (não a do OpenShift) |
| `oc get --raw /version` | versão do Kubernetes direto da API |
| `oc get clusterversion` | versão do OpenShift, condições e histórico (exige permissão) |

## Antes e depois

Nada a verificar antes. Depois: se o servidor não aparecer, cheque `oc whoami --show-server` e `oc get --raw /readyz`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
Client Version: 4.22.0
Kustomize Version: v5.x.x
Server Version: 4.22.0
Kubernetes Version: v1.xx.x
```

## Erros comuns

- Erro de conexão após a linha do cliente: o cliente está íntegro; o problema é kubeconfig, rede ou API.
- `Server Version` ausente para developer: sem permissão de ler o ClusterVersion.

## Ajuda e documentação

```bash
oc version --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Comando de leitura; nada a desfazer.
