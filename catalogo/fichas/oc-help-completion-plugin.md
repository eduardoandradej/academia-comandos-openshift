# Ficha: `oc help`, `oc options`, `oc completion`, `oc plugin`

> **Impacto:** LEITURA (help/options) · MUTAÇÃO LOCAL (instalar completion/plugin) · **Perfil mínimo:** nenhum · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [CLI-002](../../trilhas/01-cli/exercicios/CLI-002.md), [CLI-003](../../trilhas/01-cli/exercicios/CLI-003.md), [CLI-012](../../trilhas/01-cli/exercicios/CLI-012.md)

## Quando usar

Para descobrir comandos e flags sem sair do terminal, acelerar a digitação e estender a CLI.

## Forma canônica

```bash
oc get --help
```

## Sintaxe

```text
oc help | oc <cmd> --help | oc options
oc completion bash
oc plugin list
```

## Exemplos no HomeLab

```bash
oc get --help | sed -n '/Examples:/,/Options:/p'
oc options | grep -- --request-timeout
source <(oc completion bash)
oc plugin list
```

## Flags principais

| Item | Efeito |
|---|---|
| `--help`/`-h` | ajuda do subcomando |
| `oc options` | flags globais |
| `oc completion bash` | script de completion |
| `oc plugin list` | executáveis `oc-*` no PATH |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc explain` | documenta recursos (campos), não comandos |
| `man` | não há página de manual do `oc`; use `--help` |

## Antes e depois

Antes de adaptar um comando novo: leia `Examples:`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
Examples:
  # List all pods in ps output format
  oc get pods
```

## Erros comuns

- `unknown flag`: a flag não existe naquele subcomando; procure com `--help | grep`.

## Ajuda e documentação

```bash
oc help
oc completion --help
oc plugin --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`rm ~/.local/share/bash-completion/completions/oc` e `rm ~/.local/bin/oc-*`.
