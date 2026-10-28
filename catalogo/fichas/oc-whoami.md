# Ficha: `oc whoami`

> **Impacto:** LEITURA (`-t` revela token: VERMELHO se exibido) · **Perfil mínimo:** qualquer autenticado · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [ORI-002](../../trilhas/00-orientacao/exercicios/ORI-002.md), [ORI-004](../../trilhas/00-orientacao/exercicios/ORI-004.md), [CLI-005](../../trilhas/01-cli/exercicios/CLI-005.md)

## Quando usar

Antes de qualquer exercício: confirmar identidade, servidor, contexto e Console. É a primeira linha de defesa contra agir no perfil errado.

## Forma canônica

```bash
oc whoami
```

## Sintaxe

```text
oc whoami [--show-server | --show-context | --show-console | -t]
```

## Exemplos no HomeLab

```bash
oc whoami
oc whoami --show-server        # https://api.ocp.example.lab:6443
oc whoami --show-context
oc whoami --show-console       # https://console-openshift-console.apps.ocp.example.lab
oc whoami -t | wc -c           # prova que há token sem exibi-lo
oc auth whoami                 # usuário e grupos (clientes recentes)
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--show-server` | URL da API do contexto |
| `--show-context` | nome do contexto |
| `--show-console` | URL da Console Web |
| `-t`, `--show-token` | imprime o token — **nunca** em tela compartilhada |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `whoami` (Linux) | usuário do sistema operacional, não do cluster |
| `oc config current-context` | lê só o arquivo local; não valida a sessão |
| `oc auth whoami` | inclui grupos (SelfSubjectReview) |

## Antes e depois

Antes de mutar: `oc whoami` e `oc project -q`. Depois de `oc login`/`oc logout`: `oc whoami` prova o novo estado.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
developer
https://api.ocp.example.lab:6443
ac01-cli/api-ocp-example-lab:6443/developer
```

## Erros comuns

- `error: You must be logged in to the server (Unauthorized)`: token expirado ou revogado → `oc login`.
- `error: no token is currently in use for this session`: autenticação por certificado (kubeconfig do instalador).

## Ajuda e documentação

```bash
oc whoami --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura. Se um token vazou, revogue com `oc logout` na sessão correspondente.
