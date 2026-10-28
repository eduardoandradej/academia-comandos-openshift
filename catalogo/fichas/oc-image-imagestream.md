# Ficha: `oc image info`, ImageStreams, `oc tag` e gatilhos

> **Impacto:** LEITURA (image info) · MUTAÇÃO LOCAL REVERSÍVEL (ImageStreams) · **Perfil mínimo:** developer; admin para registry e políticas · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [IMG-001](../../trilhas/10-imagens/exercicios/IMG-001.md), [IMG-005](../../trilhas/10-imagens/exercicios/IMG-005.md), [IMG-006](../../trilhas/10-imagens/exercicios/IMG-006.md), [IMG-007](../../trilhas/10-imagens/exercicios/IMG-007.md), [IMG-008](../../trilhas/10-imagens/exercicios/IMG-008.md), [IMG-014](../../trilhas/10-imagens/exercicios/IMG-014.md)

## Quando usar

Para inspecionar imagens sem baixá-las e controlar, por ImageStream, qual digest cada tag representa e quando os Deployments mudam.

## Forma canônica

```bash
oc image info registry.access.redhat.com/ubi9/httpd-24:latest
```

## Sintaxe

```text
oc image info IMAGEM [-o json] [--filter-by-os=linux/amd64] [--show-multiarch]
oc image extract IMAGEM --path /na/imagem:/local [--confirm]
oc create imagestream NOME ; oc import-image IS:TAG --from=IMAGEM --confirm [--scheduled]
oc tag ORIGEM IS:TAG [--alias] [--scheduled] [--reference-policy=source|local] ; oc tag -d IS:TAG
oc set image-lookup IS [--enabled=false] ; oc set triggers deploy/X --from-image=IS:TAG --containers=C [--manual|--auto]
```

## Exemplos no HomeLab

```bash
oc image info registry.access.redhat.com/ubi9/httpd-24:latest -o json | jq -r .digest
oc create imagestream ac10-web -n ac10-imagens
oc import-image ac10-web:v1 --from=registry.access.redhat.com/ubi9/httpd-24:latest --confirm -n ac10-imagens
oc tag ac10-web:v1 ac10-web:prod -n ac10-imagens
oc set image-lookup ac10-web -n ac10-imagens
oc set triggers deployment/ac10-app --from-image=ac10-web:prod --containers=httpd-24 -n ac10-imagens
oc get istag -n ac10-imagens
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--confirm` (import-image) | cria a tag se ela não existir |
| `--alias` (tag) | a tag segue outra tag em vez de copiar o digest |
| `--scheduled` | reimporta periodicamente da origem |
| `--reference-policy` | `source` (padrão; pods baixam da origem) ou `local` (exige registry interno) |
| `--filter-by-os` | escolhe a plataforma de uma imagem multiarquitetura |

## Comparação com comandos próximos

| | Tag de registry | ImageStreamTag |
|---|---|---|
| Quem move | quem publica no registry | o projeto (`oc tag`, importação) |
| Histórico | não | sim (`status.tags[].items`) |
| Dispara rollout | não | sim, com gatilho |
| Nome curto em Deployment | não | sim, com image-lookup |

## Antes e depois

Antes de usar uma imagem: `oc image info` (porta, usuário, digest). Depois: `imageID` do pod e histórico da istag.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME       IMAGE REPOSITORY   TAGS            UPDATED
ac10-web                      prod,v1,atual   2 minutes ago
```

## Erros comuns

- `ErrImagePull` com `image: ac10-web:v1`: image-lookup desligado (TS-031).
- Tag movida sem rollout: gatilho ausente/pausado ou contêiner errado (TS-032).
- `InvalidImageName`: maiúsculas ou caracteres inválidos (TS-033).
- `manifest unknown`: tag/repositório inexistente.
- `IMAGE REPOSITORY` vazio: registry interno desligado; use `referencePolicy: Source`.

## Ajuda e documentação

```bash
oc image info --help
oc import-image --help
oc tag --help
oc set triggers --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc tag -d IS:TAG`; `oc delete imagestream <nome>`; `oc set triggers deploy/X --remove-all`.
