# Ficha: `oc label` e `oc annotate`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL (só metadados) · **Perfil mínimo:** developer (objetos do projeto) / admin (namespace) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [PRJ-003](../../trilhas/03-projetos/exercicios/PRJ-003.md), [PRJ-004](../../trilhas/03-projetos/exercicios/PRJ-004.md), [PRJ-005](../../trilhas/03-projetos/exercicios/PRJ-005.md), [PRJ-012](../../trilhas/03-projetos/exercicios/PRJ-012.md), [ORI-014](../../trilhas/00-orientacao/exercicios/ORI-014.md)

## Quando usar

Para adicionar, trocar ou remover rótulos (identidade e seleção) e anotações (descrição e configuração lida por controladores).

## Forma canônica

```bash
oc label configmap/ac03-rotulos ambiente=treino -n ac03-projetos
```

## Sintaxe

```text
oc label TIPO/NOME | TIPO -l SELETOR  chave=valor... | chave-  [--overwrite] [--list] [--dry-run=server] [--local -f ARQ -o yaml]
oc annotate (mesma sintaxe)
```

## Exemplos no HomeLab

```bash
oc label configmap/ac03-rotulos ambiente=treino -n ac03-projetos
oc label configmap/ac03-rotulos ambiente=revisao --overwrite -n ac03-projetos
oc label configmap/ac03-rotulos ambiente- -n ac03-projetos
oc label configmap -l camada=web exposto=sim -n ac03-projetos --dry-run=server
oc annotate configmap/ac03-notas academy.openshift.dev/autor=estudante -n ac03-projetos
oc create configmap x --from-literal=a=1 --dry-run=client -o yaml | oc label --local -f - academy.openshift.dev/managed-by=academia -o yaml
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--overwrite` | permite trocar valor existente |
| `chave-` | remove a chave |
| `--list` | lista rótulos/anotações do objeto |
| `-l` | aplica a todos que casam com o seletor |
| `--local -f -` | altera um manifesto sem contatar a API |
| `--dry-run=server` | simula com validação do servidor |

## Comparação com comandos próximos

| | Rótulo | Anotação |
|---|---|---|
| Seleciona com `-l` | sim | não |
| Valor | até 63 caracteres, conjunto restrito | texto livre (limite total ~256 KiB) |
| Uso | identidade, agrupamento | descrição, autoria, comportamento de controladores |

## Antes e depois

Antes de alterar em lote: `oc get ... -l <seletor> -o name` e `--dry-run=server`. Depois: `--show-labels` ou `--list`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
configmap/ac03-rotulos labeled
configmap/ac03-notas annotated
```

## Erros comuns

- `already has a value (...), and --overwrite is false`: acrescente `--overwrite` se a troca for intencional.
- `Invalid value: ... a valid label must be ...`: caractere fora do permitido (acentos, espaços) ou tamanho.
- `Forbidden ... namespaces`: developer não altera o objeto Namespace.

## Ajuda e documentação

```bash
oc label --help
oc annotate --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Remova com `chave-`, ou restaure o valor anterior com `--overwrite`.
