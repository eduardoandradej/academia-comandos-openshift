# Trilha 10 — Imagens e registries

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Entender e controlar imagens: anatomia da referência, tag × digest, o que está rodando de fato, metadados que
decidem se a imagem roda no OpenShift, política de pull, ImageStreams (importar, promover, alias, image-lookup,
gatilhos, importação agendada), o registry interno e as políticas do cluster (somente leitura), `oc image extract`,
`oc new-app` e um roteiro de diagnóstico de pull.

> Prefere só os comandos com a explicação? Veja o [guia direto 10](../../guia/10-imagens.md).

## Pré-requisitos

- Trilhas 00–05 (em especial DEP-005, imagem por digest).
- Acesso de saída a `registry.access.redhat.com` (na `ocp-admin` e no SNO).
- **REQUER PREPARAÇÃO:** pull de `ubi9/httpd-24` (cache) e, no IMG-008, de `ubi8/httpd-24` (~150 MB, uma vez).
- **Registry interno:** desligado no HomeLab (confira com o IMG-010). Tudo aqui usa `referencePolicy: Source`;
  builds, `push` e `referencePolicy: Local` **REQUEREM PREPARAÇÃO** (ativar o registry com armazenamento — mudança de
  cluster, fora da Academia).
- IMG-010 e IMG-011 usam o perfil `admin`, **somente leitura**.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [IMG-001](exercicios/IMG-001.md) | Anatomia de uma referência de imagem | LEITURA |
| [IMG-002](exercicios/IMG-002.md) | Que imagem está rodando de verdade | MUTAÇÃO LOCAL |
| [IMG-003](exercicios/IMG-003.md) | Configuração da imagem antes de rodar: usuário, portas, volumes | LEITURA |
| [IMG-004](exercicios/IMG-004.md) | Política de pull: Always, IfNotPresent e Never | MUTAÇÃO LOCAL |
| [IMG-005](exercicios/IMG-005.md) | ImageStream: importar uma imagem externa | MUTAÇÃO LOCAL |
| [IMG-006](exercicios/IMG-006.md) | Tags: apontar, mover, criar alias e apagar | MUTAÇÃO LOCAL |
| [IMG-007](exercicios/IMG-007.md) | Usar ImageStream em Deployment: image-lookup | MUTAÇÃO LOCAL |
| [IMG-008](exercicios/IMG-008.md) | Gatilho de imagem: atualizar o Deployment quando a tag muda | MUTAÇÃO LOCAL |
| [IMG-009](exercicios/IMG-009.md) | Importação periódica e política de referência | MUTAÇÃO LOCAL |
| [IMG-010](exercicios/IMG-010.md) | O registry interno visto pelo admin (somente leitura) | LEITURA |
| [IMG-011](exercicios/IMG-011.md) | Políticas de imagem do cluster: registries permitidos e espelhos | LEITURA |
| [IMG-012](exercicios/IMG-012.md) | Extrair um arquivo de uma imagem sem rodá-la | LEITURA |
| [IMG-013](exercicios/IMG-013.md) | oc new-app a partir de ImageStream | MUTAÇÃO LOCAL |
| [IMG-014](exercicios/IMG-014.md) | Roteiro de diagnóstico de imagens | MUTAÇÃO LOCAL |
| [IMG-015](exercicios/IMG-015.md) | Circuito de imagens e encerramento da trilha | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/10-imagens/`](../../solucoes/10-imagens/). Ficha:
[`oc-image-imagestream`](../../catalogo/fichas/oc-image-imagestream.md).
Cenários: [TS-031](../../cenarios/troubleshooting/TS-031.md) (nome curto sem image-lookup),
[TS-032](../../cenarios/troubleshooting/TS-032.md) (tag movida sem efeito),
[TS-033](../../cenarios/troubleshooting/TS-033.md) (InvalidImageName).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 10
scripts/academy show IMG-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac10-imagens` | IMG-002/IMG-004 | IMG-015 |
| pods de teste `ac10-*` | IMG-002, IMG-004, IMG-014 | no próprio exercício |
| ImageStream `ac10-web` (tags `v1`, `v2`, `prod`, `atual`...) | IMG-005 a IMG-009 | IMG-015 |
| Deployments `ac10-app`, `ac10-novo` | IMG-007, IMG-013 | IMG-013 / IMG-015 |
| arquivos extraídos em `/tmp/ac10` | IMG-012 | IMG-012 / IMG-015 |

Nenhum exercício altera o registry interno, `image.config.openshift.io` ou espelhos (mudanças que reiniciariam o nó).
