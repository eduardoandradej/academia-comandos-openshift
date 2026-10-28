# Ficha: `oc get --raw`

> **Impacto:** LEITURA (somente GET nesta Academia) · **Perfil mínimo:** qualquer autenticado (endpoints de saúde) / conforme RBAC · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [ORI-005](../../trilhas/00-orientacao/exercicios/ORI-005.md), [CLI-011](../../trilhas/01-cli/exercicios/CLI-011.md), [CON-015](../../trilhas/02-consultas/exercicios/CON-015.md)

## Quando usar

Ler endpoints da API sem comando próprio (`/readyz`, `/livez`, `/version`) e entender a URL por trás de cada `oc get`.

## Forma canônica

```bash
oc get --raw /readyz
```

## Sintaxe

```text
oc get --raw CAMINHO
```

## Exemplos no HomeLab

```bash
oc get --raw /readyz; echo
oc get --raw '/readyz?verbose' | grep -v '^\[+\]'
oc get --raw /version | jq -r .gitVersion
oc get --raw /apis/apps/v1/namespaces/ac02-consultas/deployments | jq -r '.items[].metadata.name'
```

## Flags principais

| Caminho | Conteúdo |
|---|---|
| `/readyz`, `/livez` | saúde da API |
| `/version` | versão do Kubernetes |
| `/api/v1/...` | grupo core |
| `/apis/<grupo>/<versão>/...` | demais grupos |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc get <tipo>` | mesma consulta, com formatação |
| `curl -k https://api...:6443/readyz` | sem credenciais |
| `oc get <tipo> -v=6` | mostra a URL usada |

## Antes e depois

Antes de qualquer trilha: `/readyz`. Para aprender a API: compare com `-v=6`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
ok
```

## Erros comuns

- `the server could not find the requested resource`: caminho (plural, grupo, versão).

## Ajuda e documentação

```bash
oc get --help | grep -A2 -- '--raw'
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura; nada a desfazer.
