# Trilha 08 — ConfigMaps e Secrets

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Separar configuração da imagem: ConfigMaps por literal, arquivo e arquivo de variáveis; consumo como variáveis e como
arquivos; o que se atualiza sozinho e o que exige reinício; Secrets genéricos, TLS e de registry; imutabilidade;
`subPath` em um arquivo real do httpd; volumes projetados; `oc extract`/`oc set data`; atualização declarativa e quem
pode ler os seus Secrets.

> Prefere só os comandos com a explicação? Veja o [guia direto 08](../../guia/08-config.md).

## Pré-requisitos

- Trilhas 00–05 (em especial a 05, Deployments).
- **REQUER PREPARAÇÃO:** pull de `registry.access.redhat.com/ubi9/httpd-24`.
- `openssl`, `curl` e `jq` na `ocp-admin`.
- O CFG-014 usa o perfil `admin` só para leitura e para um projeto rascunho `ac08-rascunho`, apagado no próprio exercício.
- **Todos os Secrets usam valores fictícios.** Mesmo assim, não cole saídas de Secrets em chats, issues ou commits.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [CFG-001](exercicios/CFG-001.md) | Criar ConfigMaps: literal, arquivo e arquivo de variáveis | MUTAÇÃO LOCAL |
| [CFG-002](exercicios/CFG-002.md) | Injetar ConfigMap como variáveis de ambiente | MUTAÇÃO LOCAL |
| [CFG-003](exercicios/CFG-003.md) | Montar ConfigMap como arquivos | MUTAÇÃO LOCAL |
| [CFG-004](exercicios/CFG-004.md) | Atualizar configuração: arquivos se atualizam, variáveis não | MUTAÇÃO LOCAL |
| [CFG-005](exercicios/CFG-005.md) | Secrets: criar e ler sem expor | MUTAÇÃO LOCAL |
| [CFG-006](exercicios/CFG-006.md) | Consumir Secrets: variáveis e arquivos | MUTAÇÃO LOCAL |
| [CFG-007](exercicios/CFG-007.md) | Secrets tipados: TLS | MUTAÇÃO LOCAL |
| [CFG-008](exercicios/CFG-008.md) | Pull secret e service account | MUTAÇÃO LOCAL |
| [CFG-009](exercicios/CFG-009.md) | ConfigMaps e Secrets imutáveis | MUTAÇÃO LOCAL |
| [CFG-010](exercicios/CFG-010.md) | Um arquivo de configuração real: conf.d do httpd com subPath | MUTAÇÃO LOCAL |
| [CFG-011](exercicios/CFG-011.md) | Volume projetado: ConfigMap, Secret e Downward API no mesmo diretório | MUTAÇÃO LOCAL |
| [CFG-012](exercicios/CFG-012.md) | Extrair e atualizar: oc extract e oc set data | MUTAÇÃO LOCAL |
| [CFG-013](exercicios/CFG-013.md) | Atualizar configuração de forma declarativa | MUTAÇÃO LOCAL |
| [CFG-014](exercicios/CFG-014.md) | Quem pode ler seus Secrets | LEITURA |
| [CFG-015](exercicios/CFG-015.md) | Circuito de configuração e encerramento da trilha | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/08-config/`](../../solucoes/08-config/). Fichas:
[`oc-configmap-secret`](../../catalogo/fichas/oc-configmap-secret.md), [`oc-set-volume`](../../catalogo/fichas/oc-set-volume.md).
Cenários: [TS-025](../../cenarios/troubleshooting/TS-025.md) (CreateContainerConfigError),
[TS-026](../../cenarios/troubleshooting/TS-026.md) (alterei o ConfigMap e nada mudou),
[TS-027](../../cenarios/troubleshooting/TS-027.md) (Secret com bytes a mais).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 08
scripts/academy show CFG-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac08-config` com ConfigMaps `ac08-*` e Secrets fictícios | CFG-001, CFG-005 | CFG-015 |
| Deployment `ac08-app` (httpd) | CFG-002 | CFG-015 |
| Deployment `ac08-web` e ConfigMap `ac08-httpd` | CFG-010 | CFG-015 |
| service account e Deployment `ac08-robo` | CFG-008 (desafio) | CFG-008 |
| projeto `ac08-rascunho` (admin) | CFG-014 (desafio) | CFG-014 |
| arquivos, certificados e chaves **de treino** em `/tmp/ac08` | CFG-001, CFG-007, CFG-012 | CFG-007, CFG-012, CFG-015 |

Nenhum exercício lê Secrets de projetos `openshift-*`, altera a criptografia do etcd ou usa credenciais reais.
