# Ficha: `oc new-project`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL · **Perfil mínimo:** developer (autoprovisionamento) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [ORI-011](../../trilhas/00-orientacao/exercicios/ORI-011.md), [CLI-007](../../trilhas/01-cli/exercicios/CLI-007.md), [CON-003](../../trilhas/02-consultas/exercicios/CON-003.md)

## Quando usar

Para criar um projeto de treino `acNN-*`. O solicitante recebe `admin` dentro do projeto.

## Forma canônica

```bash
oc new-project ac01-cli --display-name='Academia 01 - CLI'
```

## Sintaxe

```text
oc new-project NOME [--display-name=TXT] [--description=TXT] [--skip-config-write]
```

## Exemplos no HomeLab

```bash
oc auth can-i create projectrequests
oc new-project ac00-orientacao --display-name='Academia 00 - Orientação'
oc new-project ac00-rascunho --skip-config-write
oc get project ac00-orientacao -o jsonpath='{.metadata.annotations.openshift\.io/requester}{"\n"}'
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--display-name` | nome amigável |
| `--description` | descrição |
| `--skip-config-write` | não troca o projeto atual |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc create namespace` | cria Namespace puro; em geral negado ao developer |
| `oc delete project` | remove o projeto (assíncrono) |

## Antes e depois

Antes: `oc get project NOME` (já existe?). Depois: `oc project -q`, `oc get rolebindings -n NOME`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
Now using project "ac00-orientacao" on server "https://api.ocp.example.lab:6443".
```

## Erros comuns

- `AlreadyExists`: o projeto já existe (ou está em `Terminating`).
- `Forbidden ... projectrequests`: autoprovisionamento desabilitado para o usuário.

## Ajuda e documentação

```bash
oc new-project --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`scripts/safe-cleanup.sh -n NOME --execute --delete-project` e conferir `NotFound`.
