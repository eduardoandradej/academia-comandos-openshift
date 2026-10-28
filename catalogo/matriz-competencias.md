# Matriz de competências

> Para cada família: onde se aprende a **explicar**, **observar**, **executar**, **diagnosticar** e **revisar**, quais
> pré-requisitos o HomeLab precisa e o risco típico. "—" = ainda não produzido (trilha planejada).

## Progresso do repositório

| Meta | Atual | Alvo |
|---|---:|---:|
| Comandos e formas catalogados | 235 (231 distintos) | 200+ ✔ |
| Microexercícios originais | 255 | 300+ |
| Cenários de troubleshooting | 51 | 40+ ✔ |
| Fichas de comando | 38 | uma por família de comando |
| Trilhas completas | 17 de 21 | 21 |

## Matriz por família

| Família | Explicar | Observar | Executar | Diagnosticar | Revisar | Pré-requisitos | Risco |
|---|---|---|---|---|---|---|---|
| Ambiente e identidade | ORI-001, ORI-002 | ORI-002, ORI-003 | ORI-004 | TS-001 | ORI-009 | HTPasswd `homelab-users` | VERDE/AMARELO |
| Saúde do cluster | ORI-005, ORI-006 | ORI-006, ORI-007, ORI-008 | — (somente leitura) | ORI-007, ORI-008, TS-002 | ORI-009 | perfil `admin`; métricas | VERDE |
| Risco e permissão | ORI-010 | ORI-013 | ORI-014 | TS-003 | ORI-010 | — | VERDE |
| Projetos e cotas | ORI-011, ORI-012 | ORI-013 | ORI-011, ORI-012, ORI-015 | ORI-011, ORI-015 | ORI-015 | `admin` para quota | AMARELO |
| Sessão e kubeconfig | CLI-004, CLI-006 | CLI-005, CLI-006 | CLI-004, CLI-009 | TS-004, TS-005 | CLI-015 | ORI-004 | AMARELO (local) |
| Projetos e contexto | CLI-007, CLI-008 | CLI-007 | CLI-007, CLI-008 | TS-006 | CLI-015 | — | AMARELO |
| Ferramentas da CLI | CLI-002, CLI-003, CLI-012 | CLI-011 | CLI-003, CLI-012 | CLI-011, CLI-014 | CLI-015 | `bash-completion` | VERDE/AMARELO (local) |
| Tipos e esquemas | CON-001, CON-002 | CON-001, CON-002 | — | TS-007 | CON-015 | — | VERDE |
| Consulta e formatos | CON-004, CON-007 | CON-004 a CON-011 | CON-003 | CON-006, CON-009, TS-008 | CON-015 | imagem externa (alvo) | VERDE |
| Eventos e espera | CON-012, CON-014 | CON-012, CON-013 | CON-014 | CON-014, TS-009 | CON-015 | imagem externa (alvo) | VERDE/AMARELO |
| Rótulos e anotações | PRJ-003, PRJ-005 | PRJ-001, PRJ-007 | PRJ-003 a PRJ-006, PRJ-014 | PRJ-004, TS-012 | PRJ-015 | — | AMARELO |
| Seletores e donos | PRJ-008, PRJ-009 | PRJ-013 | PRJ-008, PRJ-009 | TS-010 | PRJ-015 | imagem externa | AMARELO |
| Ciclo de vida e versões | PRJ-010, PRJ-011 | PRJ-010, PRJ-011 | PRJ-011, PRJ-012 | PRJ-010, TS-011 | PRJ-015 | — | AMARELO |
| Pods: ciclo de vida | POD-001, POD-003 | POD-002, POD-014 | POD-002, POD-003, POD-011 | TS-013, TS-014 | POD-015 | imagem externa | AMARELO |
| Pods: logs e acesso | POD-004, POD-010 | POD-004, POD-005 | POD-006 a POD-009, POD-013 | POD-004, POD-013 | POD-015 | imagem externa | VERDE/AMARELO |
| Pods: recursos e QoS | POD-012 | POD-012 | POD-012 | TS-015 | POD-015 | imagem externa | AMARELO |
| Deployments e rollout | DEP-001, DEP-003, DEP-007 | DEP-008, DEP-014 | DEP-001 a DEP-007, DEP-013 | DEP-014, TS-016, TS-018 | DEP-015 | imagem externa | AMARELO |
| Jobs, CronJobs, DaemonSets | DEP-010 a DEP-012 | DEP-012 | DEP-009 a DEP-012 | DEP-010, TS-017 | DEP-015 | imagem externa | AMARELO |
| Services e DNS | SVC-001, SVC-002, SVC-005 | SVC-003, SVC-005, SVC-007 | SVC-001, SVC-002, SVC-006, SVC-008 a SVC-012 | SVC-014, TS-019 a TS-021 | SVC-015 | imagem externa | AMARELO |
| Routes e Ingress | RTE-001, RTE-002, RTE-006 | RTE-005, RTE-013 | RTE-001 a RTE-012 | RTE-014, TS-022 a TS-024 | RTE-015 | wildcard `*.apps` resolvendo | AMARELO |
| ConfigMaps e Secrets | CFG-001, CFG-004, CFG-005 | CFG-003, CFG-014 | CFG-001 a CFG-013 | CFG-004, TS-025 a TS-027 | CFG-015 | imagem externa | AMARELO |
| Storage | STO-001, STO-007, STO-011 | STO-006 | STO-002 a STO-005; STO-008 a STO-013 (REQUER PREPARAÇÃO) | STO-014, TS-028 a TS-030 | STO-015 | PV/PVC: **REQUER PREPARAÇÃO** (docs/10) | AMARELO |
| Imagens e registry | IMG-001, IMG-003, IMG-005 | IMG-002, IMG-010, IMG-011 | IMG-004 a IMG-009, IMG-012, IMG-013 | IMG-014, TS-031 a TS-033 | IMG-015 | registry interno desligado: `Local`/builds REQUER PREPARAÇÃO | AMARELO |
| Resiliência e HPA | RES-001, RES-004, RES-007 | RES-002, RES-003, RES-012 | RES-004 a RES-011, RES-013 | RES-014, TS-034 a TS-036 | RES-015 | Metrics API (HPA) | AMARELO |
| Manifestos declarativos | DCL-003, DCL-005, DCL-008 | DCL-004, DCL-006 | DCL-001 a DCL-013 | DCL-014, TS-037 a TS-039 | DCL-015 | — | AMARELO |
| Kustomize e Templates | KUS-001, KUS-010, KUS-013 | KUS-005 | KUS-002 a KUS-012 | KUS-014, TS-040 a TS-042 | KUS-015 | — | AMARELO |
| Helm | HLM-002, HLM-005, HLM-013 | HLM-004, HLM-012 | HLM-003 a HLM-011 | HLM-014, TS-043 a TS-045 | HLM-015 | cliente `helm` (REQUER PREPARAÇÃO) | AMARELO |
| RBAC e identidade | RBC-001, RBC-003, RBC-012 | RBC-010, RBC-011, RBC-013 | RBC-002 a RBC-008 | RBC-014, TS-046 a TS-048 | RBC-015 | `admin`; usuários DO280 só via docs/12 | AMARELO/VERMELHO |
| Rede e isolamento | NET-001, NET-005, NET-011 | NET-010, NET-012 | NET-002 a NET-009, NET-013 | NET-014, TS-049 a TS-051 | NET-015 | — | AMARELO |
| Operadores e manutenção | parcial: ORI-007 | ORI-007 | — (somente observação) | — | — | — | VERDE |

## Mapa de dependências do HomeLab

```mermaid
flowchart LR
  subgraph disponivel[Disponível hoje]
    API[API e OAuth] --> ID[admin e developer via HTPasswd]
    ID --> T00[Trilhas 00-16]
    IMG[Pull de registries externos] --> T02[Alvo de observação]
  end
  subgraph condicionado[Condicionado ou ausente]
    SC[StorageClass / PV] -.-> T09[Trilha 09 Storage]
    REG[Registry interno com storage] -.-> T10[Trilha 10 Imagens e builds]
    DNS[Wildcard *.apps resolvendo no cliente] -.-> T07[Trilha 07 Routes: verificar no cliente]
    MET[Metrics API] -.-> T11[Trilha 11 HPA]
    HELM[Cliente helm] -.-> T14[Trilha 14 Helm]
    LB[LoadBalancer / redes adicionais] -.-> X[Apenas conceitual no SNO]
  end
```

Legenda: setas contínuas = dependência atendida no último checkpoint; tracejadas = **REQUER PREPARAÇÃO** ou
**NÃO DISPONÍVEL NO HOME LAB ATUAL**. Confirme o estado real com `scripts/preflight.sh` (seção 7).
