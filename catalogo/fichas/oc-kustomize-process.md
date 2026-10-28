# Ficha: `oc kustomize`, `oc apply -k` e `oc process`

> **Impacto:** LEITURA (renderizar) · MUTAÇÃO LOCAL REVERSÍVEL (aplicar) · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [KUS-001](../../trilhas/13-kustomize/exercicios/KUS-001.md), [KUS-002](../../trilhas/13-kustomize/exercicios/KUS-002.md), [KUS-003](../../trilhas/13-kustomize/exercicios/KUS-003.md), [KUS-005](../../trilhas/13-kustomize/exercicios/KUS-005.md), [KUS-007](../../trilhas/13-kustomize/exercicios/KUS-007.md), [KUS-011](../../trilhas/13-kustomize/exercicios/KUS-011.md), [KUS-014](../../trilhas/13-kustomize/exercicios/KUS-014.md)

## Quando usar

Para manter uma aplicação em vários ambientes (Kustomize) ou oferecer modelos parametrizados (Templates) sem copiar YAML.

## Forma canônica

```bash
oc kustomize manifests/kustomize/overlays/dev
```

## Sintaxe

```text
oc kustomize DIR                       # renderiza
oc diff -k DIR ; oc apply -k DIR [-n NS] ; oc delete -k DIR
oc process -f ARQ|NOME [-p K=V ...] [--param-file=F] [--parameters] [-o yaml]
oc process ... | oc apply -n NS -f -
oc new-app --template=NOME -p K=V
```

## Exemplos no HomeLab

```bash
oc kustomize manifests/kustomize/base
oc diff -k manifests/kustomize/overlays/dev
oc apply -k manifests/kustomize/overlays/dev
diff <(oc kustomize manifests/kustomize/overlays/dev) <(oc kustomize manifests/kustomize/overlays/prod)
oc process -f manifests/templates/ac13-template.yaml --parameters
oc process -f manifests/templates/ac13-template.yaml -p NOME=ac13-tpl-a | oc apply -n ac13-kustomize -f -
oc new-app --template=ac13-web -p NOME=ac13-tpl-c -n ac13-kustomize
```

## Flags principais

| Campo da `kustomization.yaml` | Efeito |
|---|---|
| `resources` | arquivos/diretórios incluídos (a base, nos overlays) |
| `namespace` | namespace de todos os objetos (não use `-n` diferente) |
| `labels` (`includeSelectors: false`) | rótulos sem tocar seletores |
| `configMapGenerator`/`secretGenerator` | gera com hash e corrige referências (rollout automático) |
| `images`, `replicas` | troca imagem (tag/digest) e réplicas |
| `patches` | estratégico (`path`) ou JSON 6902 (`target` + `patch`) |

## Comparação com comandos próximos

| | Kustomize | Template |
|---|---|---|
| Base | YAML válido | YAML com `${X}` |
| Variação | overlay (transformações) | parâmetros |
| Tipos | preservados | `${X}` texto, `${{X}}` valor |
| Objeto no cluster | nenhum | Template (opcional) |

## Antes e depois

Antes de aplicar: `oc kustomize` (ou `oc process -o yaml`) e `oc diff -k`. Depois: `oc diff -k` deve dar 0.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
configmap/ac13-pagina-8t2m9hk4bc created
service/ac13-loja created
deployment.apps/ac13-loja created
route.route.openshift.io/ac13-loja created
```

## Erros comuns

- `namespace ... does not match`: `-n` contra o `namespace` do overlay (TS-040).
- `failed to find unique target for patch`: nome do alvo mudou (TS-041).
- `field is immutable` ao aplicar: rótulo entrou no seletor (`commonLabels`) (KUS-004).
- `cannot unmarshal string ... int32`: `${X}` em vez de `${{X}}` (TS-042).
- `unknown parameter name`: parâmetro inexistente (KUS-011).

## Ajuda e documentação

```bash
oc kustomize --help
oc process --help
oc explain template.parameters
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc delete -k DIR`; `oc delete all,cm,secret -l <rótulo do template>`.
