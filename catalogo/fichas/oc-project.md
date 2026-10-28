# Ficha: `oc project` e `oc projects`

> **Impacto:** LEITURA (listar) · MUTAÇÃO LOCAL (alternar) · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [ORI-011](../../trilhas/00-orientacao/exercicios/ORI-011.md), [CLI-007](../../trilhas/01-cli/exercicios/CLI-007.md), [CLI-008](../../trilhas/01-cli/exercicios/CLI-008.md)

## Quando usar

Para ver e trocar o projeto atual e listar os acessíveis.

## Forma canônica

```bash
oc project -q
```

## Sintaxe

```text
oc project [NOME] [-q]
oc projects [-q]
```

## Exemplos no HomeLab

```bash
oc project
oc project -q
oc project ac01-cli
oc projects -q | grep '^ac'
```

## Flags principais

| Flag | Efeito |
|---|---|
| `-q`, `--short` | só o nome |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc new-project` | cria e (por padrão) troca |
| `oc get projects` | lista como recurso de API (permite `-o`) |
| `oc config set-context --current --namespace` | troca sem criar contexto |

## Antes e depois

Antes de qualquer mutação: `oc project -q`. Depois de trocar: `oc config get-contexts`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
Using project "ac01-cli" on server "https://api.ocp.example.lab:6443".
```

## Erros comuns

- `error: You are not a member of project "default"`: sem papel no projeto.
- `error: A project named "x" does not exist`: nome errado ou já apagado.

## Ajuda e documentação

```bash
oc project --help
oc projects --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Volte ao projeto anterior com `oc project <anterior>`.
