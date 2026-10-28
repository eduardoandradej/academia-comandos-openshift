# Trilha 14 — Helm

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Empacotar e entregar com Helm 3: preparar o cliente com a identidade certa, anatomia de um chart, `helm template`,
releases (install, status, get), upgrade e precedência de valores, histórico e rollback, modelos (`if`, `with`,
`range`, `required`), schema de valores, `helm test`, upgrades seguros (`--atomic`), donos de objetos, auditoria de
charts publicados, combinação com Kustomize e diagnóstico.

> Prefere só os comandos com a explicação? Veja o [guia direto 14](../../guia/14-helm.md).

## Pré-requisitos

- Trilhas 12 e 13.
- **REQUER PREPARAÇÃO:** cliente `helm` para o usuário `student` — [docs/11-preparacao-helm.md](../../docs/11-preparacao-helm.md).
- **Identidade:** o Helm usa o mesmo `KUBECONFIG` do `oc`. Rode `source scripts/perfis.sh && ac-dev` e confira
  `oc whoami` = `developer` **antes de cada exercício** (o `~/.bashrc` aponta para o kubeconfig do instalador).
- Pull de `registry.access.redhat.com/ubi9/httpd-24`; curinga `*.apps` na `ocp-admin`.
- Chart de treino: [`manifests/helm/ac14-loja`](../../manifests/helm/ac14-loja/README.md) — trabalhe na cópia `/tmp/ac14/ac14-loja`.
- **Validação do autor:** o chart foi conferido estaticamente (YAML de `Chart.yaml`/`values*.yaml` e JSON do schema);
  os modelos **não** foram renderizados pelo autor (sem `helm` no ambiente de escrita). Rode `helm lint` primeiro.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [HLM-001](exercicios/HLM-001.md) | Preparar e conferir o cliente Helm | MUTAÇÃO LOCAL (cliente) |
| [HLM-002](exercicios/HLM-002.md) | Anatomia de um chart | LEITURA |
| [HLM-003](exercicios/HLM-003.md) | helm template: renderizar como o Kustomize | LEITURA |
| [HLM-004](exercicios/HLM-004.md) | Instalar uma release e ler o que ela é | MUTAÇÃO LOCAL |
| [HLM-005](exercicios/HLM-005.md) | helm upgrade e a precedência de valores | MUTAÇÃO LOCAL |
| [HLM-006](exercicios/HLM-006.md) | Histórico e rollback | MUTAÇÃO LOCAL |
| [HLM-007](exercicios/HLM-007.md) | Escrever modelos: if, with, range, default, required | LEITURA |
| [HLM-008](exercicios/HLM-008.md) | Validação de valores com values.schema.json | LEITURA |
| [HLM-009](exercicios/HLM-009.md) | helm test: verificar a release depois de instalar | MUTAÇÃO LOCAL |
| [HLM-010](exercicios/HLM-010.md) | Upgrades seguros: --wait, --timeout e --atomic | MUTAÇÃO LOCAL |
| [HLM-011](exercicios/HLM-011.md) | Releases, donos e convivência com o oc | MUTAÇÃO LOCAL |
| [HLM-012](exercicios/HLM-012.md) | Charts publicados: ler antes de instalar | LEITURA |
| [HLM-013](exercicios/HLM-013.md) | Helm, Kustomize e o oc: quem é dono de quê | LEITURA |
| [HLM-014](exercicios/HLM-014.md) | Roteiro de diagnóstico de Helm | MUTAÇÃO LOCAL |
| [HLM-015](exercicios/HLM-015.md) | Circuito de Helm e encerramento da trilha | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/14-helm/`](../../solucoes/14-helm/). Ficha: [`helm`](../../catalogo/fichas/helm.md).
Cenários: [TS-043](../../cenarios/troubleshooting/TS-043.md) (release travada em `pending-*`),
[TS-044](../../cenarios/troubleshooting/TS-044.md) (invalid ownership metadata),
[TS-045](../../cenarios/troubleshooting/TS-045.md) (`--reuse-values`).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev && oc whoami
mkdir -p /tmp/ac14 && cp -r manifests/helm/ac14-loja /tmp/ac14/
helm lint /tmp/ac14/ac14-loja
scripts/academy list --trilha 14
scripts/academy show HLM-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| cliente `helm` em `~/bin` | HLM-001 (preparação) | só se você quiser (docs/11) |
| projeto `ac14-helm` | HLM-003 | HLM-015 |
| releases `loja`, `vitrine` (e seus Secrets `sh.helm.release.v1.*`) | HLM-004, HLM-011 | HLM-011 / HLM-015 |
| repositório `openshift-helm-charts` (local) | HLM-012 | HLM-012 / HLM-015 |
| cópias em `/tmp/ac14` | HLM-001 em diante | HLM-015 |

Nenhum exercício instala charts de terceiros: o HLM-012 só os baixa e audita.
