# Ficha: `oc config`

> **Impacto:** LEITURA (view/get) · MUTAÇÃO LOCAL (set-context, use-context, rename-context) · **Perfil mínimo:** nenhum (arquivo local) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [ORI-002](../../trilhas/00-orientacao/exercicios/ORI-002.md), [CLI-006](../../trilhas/01-cli/exercicios/CLI-006.md), [CLI-008](../../trilhas/01-cli/exercicios/CLI-008.md), [CLI-009](../../trilhas/01-cli/exercicios/CLI-009.md)

## Quando usar

Para inspecionar e organizar o kubeconfig: contextos, clusters, usuários e namespace padrão — sem revelar credenciais.

## Forma canônica

```bash
oc config get-contexts
```

## Sintaxe

```text
oc config view [--minify] [-o jsonpath=...]
oc config get-contexts | get-clusters | get-users | current-context
oc config use-context NOME
oc config set-context --current --namespace=NS
oc config rename-context ANTIGO NOVO
```

## Exemplos no HomeLab

```bash
oc config view --minify
oc config get-contexts
oc config view --minify -o jsonpath='{.clusters[0].cluster.server}{"\n"}'
oc config set-context --current --namespace=ac01-cli
oc --context=dev whoami
```

## Flags principais

| Flag/subcomando | Efeito |
|---|---|
| `view --minify` | só o contexto atual |
| `view --raw` | mostra credenciais — **proibido** nesta Academia |
| `set-context --current` | altera o contexto atual |
| `--context=X` (global) | usa outro contexto só naquele comando |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc project X` | cria/usa um contexto `X/servidor/usuário` |
| `oc config set-context --current --namespace=X` | muda o namespace sem criar contexto |
| `oc config use-context` | persiste a troca no arquivo |

## Antes e depois

Antes de alterar: `oc config current-context`. Depois: `oc whoami --show-context` e `oc project -q`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
CURRENT   NAME                                          CLUSTER                     AUTHINFO                                NAMESPACE
*         ac01-cli/api-ocp-example-lab:6443/developer   api-ocp-example-lab:6443    developer/api-ocp-example-lab:6443      ac01-cli
```

## Erros comuns

- `error: current-context must exist in order to minify`: arquivo vazio/inexistente.
- `error: context "x" does not exist`: o arquivo que contém o contexto não está em `KUBECONFIG`.

## Ajuda e documentação

```bash
oc config --help
oc config view --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Desfaça `rename-context` renomeando de volta; `set-context --current --namespace=` com o valor anterior.
