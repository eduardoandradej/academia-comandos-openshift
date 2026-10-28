# Trilha 13 — Kustomize e Templates

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Uma aplicação, vários ambientes, sem copiar YAML: base e overlays do Kustomize (geradores com hash, rótulos sem
tocar seletores, `images`, `replicas`, patches estratégicos e JSON), ciclo com `-k` e limpeza de versões antigas;
Templates do OpenShift (`oc process`, parâmetros, valores gerados, `new-app --template`); e quando usar cada
ferramenta (Helm fica para a Trilha 14).

> Prefere só os comandos com a explicação? Veja o [guia direto 13](../../guia/13-kustomize.md).

## Pré-requisitos

- Trilha 12 (apply, diff, patch, prune).
- `oc` 4.x (traz o Kustomize embutido: `oc kustomize`, `oc apply -k`); `jq` e `python3-pyyaml` na `ocp-admin`.
- **REQUER PREPARAÇÃO:** pull de `registry.access.redhat.com/ubi9/httpd-24`; curinga `*.apps` na `ocp-admin`.
- Exemplos: [`manifests/kustomize/`](../../manifests/kustomize/README.md) (base e overlays `dev`/`prod`) e
  [`manifests/templates/ac13-template.yaml`](../../manifests/templates/ac13-template.yaml). Trabalhe na cópia
  `/tmp/ac13/kustomize`.
- **Validação do autor:** os arquivos foram conferidos como YAML válido; a renderização com `oc kustomize` ainda
  **não** foi executada pelo autor (sem `oc` no ambiente de escrita). Se algo não renderizar, abra uma issue.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [KUS-001](exercicios/KUS-001.md) | Ler uma base Kustomize e renderizá-la | LEITURA |
| [KUS-002](exercicios/KUS-002.md) | Aplicar, comparar e remover com -k | MUTAÇÃO LOCAL |
| [KUS-003](exercicios/KUS-003.md) | Geradores: ConfigMaps e Secrets com hash | MUTAÇÃO LOCAL |
| [KUS-004](exercicios/KUS-004.md) | Rótulos comuns e o cuidado com seletores | LEITURA |
| [KUS-005](exercicios/KUS-005.md) | Overlays: dev e prod a partir da mesma base | MUTAÇÃO LOCAL |
| [KUS-006](exercicios/KUS-006.md) | Transformadores de imagem e réplicas | MUTAÇÃO LOCAL |
| [KUS-007](exercicios/KUS-007.md) | Patches: estratégico e JSON 6902 | MUTAÇÃO LOCAL |
| [KUS-008](exercicios/KUS-008.md) | Criar um overlay novo do zero | MUTAÇÃO LOCAL |
| [KUS-009](exercicios/KUS-009.md) | Ciclo completo com Kustomize: diff, apply e prune de versões antigas | MUTAÇÃO LOCAL |
| [KUS-010](exercicios/KUS-010.md) | Templates do OpenShift: ler sem aplicar | LEITURA |
| [KUS-011](exercicios/KUS-011.md) | oc process: parâmetros, arquivos de parâmetros e valores gerados | MUTAÇÃO LOCAL |
| [KUS-012](exercicios/KUS-012.md) | Template guardado no projeto e oc new-app --template | MUTAÇÃO LOCAL |
| [KUS-013](exercicios/KUS-013.md) | Kustomize × Template × Helm: escolher a ferramenta | LEITURA |
| [KUS-014](exercicios/KUS-014.md) | Roteiro de diagnóstico de Kustomize e Templates | LEITURA |
| [KUS-015](exercicios/KUS-015.md) | Circuito de Kustomize e Templates e encerramento da trilha | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/13-kustomize/`](../../solucoes/13-kustomize/). Ficha:
[`oc-kustomize-process`](../../catalogo/fichas/oc-kustomize-process.md).
Cenários: [TS-040](../../cenarios/troubleshooting/TS-040.md) (namespace em conflito),
[TS-041](../../cenarios/troubleshooting/TS-041.md) (patch sem alvo),
[TS-042](../../cenarios/troubleshooting/TS-042.md) (`${X}` × `${{X}}`).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
mkdir -p /tmp/ac13 && cp -r manifests/kustomize /tmp/ac13/
scripts/academy list --trilha 13
scripts/academy show KUS-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac13-kustomize` (base, instâncias do Template) | KUS-002 | KUS-015 |
| projetos `ac13-dev` e `ac13-prod` (overlays) | KUS-005 | KUS-015 |
| projeto `ac13-homolog` | KUS-008 | KUS-008 / KUS-015 |
| ConfigMaps/Secrets gerados `ac13-pagina-*`, `ac13-api-*` | KUS-002 em diante | KUS-003, KUS-009, KUS-015 |
| Template `ac13-web` guardado no projeto | KUS-012 | KUS-012 |
| cópia de trabalho `/tmp/ac13` | KUS-001 | KUS-015 |
