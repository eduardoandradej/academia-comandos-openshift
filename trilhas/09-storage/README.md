# Trilha 09 — Storage

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Onde os dados vivem e por quanto tempo: mapa dos volumes, `emptyDir` compartilhado, em Deployment e em memória,
armazenamento efêmero e despejo, inventário de storage do cluster, anatomia de PVC, PVC montado e persistente,
ligação PV × PVC, modos de acesso no SNO, expansão, StatefulSet com um PVC por réplica e diagnóstico.

> Prefere só os comandos com a explicação? Veja o [guia direto 09](../../guia/09-storage.md).

## Pré-requisitos

- Trilhas 00–05 e 08.
- **REQUER PREPARAÇÃO** para PV/PVC (STO-008 a STO-013 e partes do STO-014/015): o HomeLab tem **0 StorageClasses** e
  a quota da Academia proíbe PVCs. Siga [docs/10-preparacao-storage.md](../../docs/10-preparacao-storage.md):
  - **opção A** (recomendada): NFS no HD do `kvm-server` + 3 PVs estáticos de 1Gi (`export SC=ac09-nfs`);
  - **opção B**: LVM Storage com um disco extra no SNO (`export SC=lvms-vg1`) — necessária para expansão (STO-012) e RWOP.
- Sem preparação: STO-001 a STO-007 e os cenários TS-028 a TS-030 funcionam normalmente.
- Pull de `registry.access.redhat.com/ubi9/httpd-24`.
- O STO-006 usa o perfil `admin`, **somente leitura**.

## Exercícios

| ID | Título | Preparação | Impacto |
|---|---|---|---|
| [STO-001](exercicios/STO-001.md) | Mapa dos volumes: o que cada tipo guarda e por quanto tempo | — | LEITURA |
| [STO-002](exercicios/STO-002.md) | emptyDir compartilhado entre contêineres | — | MUTAÇÃO LOCAL |
| [STO-003](exercicios/STO-003.md) | emptyDir em Deployment: o que sobrevive a quê | — | MUTAÇÃO LOCAL |
| [STO-004](exercicios/STO-004.md) | emptyDir em memória: rápido e contado como RAM | — | MUTAÇÃO LOCAL |
| [STO-005](exercicios/STO-005.md) | Armazenamento efêmero: requests, limits e despejo | — | MUTAÇÃO LOCAL |
| [STO-006](exercicios/STO-006.md) | Storage do cluster visto pelo admin (somente leitura) | — | LEITURA |
| [STO-007](exercicios/STO-007.md) | Anatomia de um PVC sem criar nada | — | LEITURA |
| [STO-008](exercicios/STO-008.md) | Primeiro PVC: dados que sobrevivem ao pod | **REQUER PREPARAÇÃO** | MUTAÇÃO LOCAL |
| [STO-009](exercicios/STO-009.md) | PVC e montagem em um comando: oc set volume --claim-size | **REQUER PREPARAÇÃO** | MUTAÇÃO LOCAL |
| [STO-010](exercicios/STO-010.md) | Ligação PV × PVC: claimRef, tamanho e seletores | **REQUER PREPARAÇÃO** (A) | MUTAÇÃO LOCAL |
| [STO-011](exercicios/STO-011.md) | Modos de acesso no SNO: RWO, RWX e ReadWriteOncePod | **REQUER PREPARAÇÃO** | MUTAÇÃO LOCAL |
| [STO-012](exercicios/STO-012.md) | Expandir um PVC | **REQUER PREPARAÇÃO** (B) | MUTAÇÃO LOCAL |
| [STO-013](exercicios/STO-013.md) | StatefulSet: um PVC por réplica | **REQUER PREPARAÇÃO** | MUTAÇÃO LOCAL |
| [STO-014](exercicios/STO-014.md) | Roteiro de diagnóstico de storage | parcial | MUTAÇÃO LOCAL |
| [STO-015](exercicios/STO-015.md) | Circuito de storage e encerramento da trilha | parcial | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/09-storage/`](../../solucoes/09-storage/). Fichas:
[`oc-pvc-storage`](../../catalogo/fichas/oc-pvc-storage.md), [`oc-set-volume`](../../catalogo/fichas/oc-set-volume.md).
Cenários: [TS-028](../../cenarios/troubleshooting/TS-028.md) (PVC que nunca liga),
[TS-029](../../cenarios/troubleshooting/TS-029.md) (dados sumiram com o deploy),
[TS-030](../../cenarios/troubleshooting/TS-030.md) (Evicted por disco).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 09
scripts/academy show STO-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac09-storage` | STO-002 | STO-015 |
| pods `ac09-compartilhado`, `ac09-guloso` | STO-002, STO-005 | no próprio exercício |
| Deployment `ac09-app` | STO-003 | STO-015 |
| PVCs `ac09-dados`, `ac09-logs`, `ac09-escolhido`, `dados-ac09-sts-*` | STO-008 a STO-013 | no próprio exercício / STO-015 |
| StatefulSet e Service `ac09-sts` | STO-013 | STO-013 |
| PVs `ac09-pv-01..03` (opção A, admin) | preparação | reciclados no STO-015; removidos só pelo roteiro de preparação |

`emptyDir` e armazenamento efêmero gravam no SSD do nó: os exercícios usam no máximo dezenas de MiB.
