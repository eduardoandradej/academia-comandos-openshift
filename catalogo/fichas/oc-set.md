# Ficha: `oc set` (image, env, resources)

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL (gera revisão nova) · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [DEP-003](../../trilhas/05-deployments/exercicios/DEP-003.md), [DEP-005](../../trilhas/05-deployments/exercicios/DEP-005.md), [DEP-006](../../trilhas/05-deployments/exercicios/DEP-006.md)

## Quando usar

Para alterar partes do template de um Deployment sem editar YAML: imagem, variáveis, recursos.

## Forma canônica

```bash
oc set env deployment/ac05-web VERSAO=v2 -n ac05-deploy
```

## Sintaxe

```text
oc set image TIPO/NOME CONTÊINER=IMAGEM | '*=IMAGEM'
oc set env TIPO/NOME CHAVE=valor | CHAVE- | --list
oc set resources TIPO/NOME [-c C] --requests=cpu=..,memory=.. --limits=cpu=..,memory=..
```

## Exemplos no HomeLab

```bash
oc get deployment ac05-web -n ac05-deploy -o jsonpath='{.spec.template.spec.containers[*].name}'
oc set image deployment/ac05-web httpd-24=registry.access.redhat.com/ubi9/httpd-24@sha256:<digest> -n ac05-deploy
oc set env deployment/ac05-web VERSAO=v2 COR=azul -n ac05-deploy
oc set env deployment/ac05-web COR- -n ac05-deploy
oc set env deployment/ac05-web --list -n ac05-deploy
oc set resources deployment/ac05-web --requests=cpu=25m,memory=48Mi --limits=cpu=150m,memory=128Mi -n ac05-deploy
```

## Flags principais

| Item | Efeito |
|---|---|
| `CONTÊINER=IMAGEM` | troca a imagem de um contêiner (nome exato) |
| `*=IMAGEM` | todos os contêineres |
| `CHAVE-` | remove a variável |
| `--list` | lista variáveis |
| `--dry-run=server -o yaml` | mostra o resultado sem gravar |

## Comparação com comandos próximos

| Forma | Quando |
|---|---|
| `oc set` | mudança pontual e rápida |
| `oc patch` | campos sem subcomando próprio (estratégia, prazos) |
| arquivo + `oc apply` | mudança versionada e repetível |

## Antes e depois

Depois: `oc rollout status`; agrupe várias com `pause`/`resume`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
deployment.apps/ac05-web image updated
deployment.apps/ac05-web updated
```

## Erros comuns

- `unable to find container named "x"`: confira o nome do contêiner.
- recusa do LimitRange ao definir limits acima do máximo.

## Ajuda e documentação

```bash
oc set --help
oc set image --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc rollout undo` volta ao template anterior.
