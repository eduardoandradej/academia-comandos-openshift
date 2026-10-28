# Trilhas

> 21 trilhas progressivas (00 a 20). **Disponíveis:** 00 a 09. As demais são **planejadas**: as pastas só passam a
> existir quando o conteúdo estiver escrito — nada aqui finge estar pronto.

| ID | Trilha | Status | Foco | Dependências do HomeLab |
|---|---|---|---|---|
| 00 | [Orientação e segurança](00-orientacao/README.md) | **disponível** (15) | perfis, saúde, risco, projeto de treino, limpeza | HTPasswd |
| 01 | [Navegação e CLI](01-cli/README.md) | **disponível** (15) | login, whoami, config, project, ajuda, plugins | ORI-004 |
| 02 | [Leitura e inspeção](02-consultas/README.md) | **disponível** (15) | get, describe, explain, jsonpath, jq, eventos, wait | imagem externa |
| 03 | [Projetos e metadados](03-projetos/README.md) | **disponível** (15) | labels, annotations, seletores, ownerReferences, finalizers (leitura) | imagem externa (a partir do PRJ-008) |
| 04 | [Pods e contêineres](04-pods/README.md) | **disponível** (15) | run, logs, exec, rsh, cp, attach, port-forward, debug, QoS | imagem externa |
| 05 | [Deployments e workloads](05-deployments/README.md) | **disponível** (15) | rollout, revisões, undo, set, estratégias, Job, CronJob, DaemonSet | imagem externa |
| 06 | [Services e DNS](06-servicos/README.md) | **disponível** (15) | ClusterIP, portas, EndpointSlices, DNS, azul/verde, headless, diagnóstico | imagem externa |
| 07 | [Routes e Ingress](07-rotas/README.md) | **disponível** (15) | expose, hostname, path, TLS edge/passthrough/reencrypt, pesos, Ingress | wildcard `*.apps` no cliente |
| 08 | [ConfigMaps e Secrets](08-config/README.md) | **disponível** (15) | literal/arquivo/env-file, envFrom, volumes, subPath, Secrets TLS e de registry, imutáveis, extract | — |
| 09 | [Storage](09-storage/README.md) | **disponível** (15) | emptyDir, efêmero, PVC, modos de acesso, expansão, StatefulSet | PV/PVC: **REQUER PREPARAÇÃO** ([docs/10](../docs/10-preparacao-storage.md)) |
| 10 | Imagens e registries | planejada | image info, ImageStreams, import-image | registry interno sem storage |
| 11 | Resiliência | planejada | probes, requests/limits, HPA, PDB | Metrics API |
| 12 | Manifestos declarativos | planejada | create/apply/replace/patch, diff, dry-run | — |
| 13 | Kustomize e Templates | planejada | bases, overlays, oc process | — |
| 14 | Helm | planejada | template, install, upgrade, rollback | cliente `helm` |
| 15 | Usuários, identidade e RBAC | planejada | HTPasswd, grupos, roles, can-i | perfil admin |
| 16 | Rede e isolamento | planejada | NetworkPolicy, TLS, DNS | — |
| 17 | Administração de recursos | planejada | quotas, limit ranges, SA, SCC (observação) | perfil admin |
| 18 | Operadores e manutenção | planejada | CO, CVO, OLM, MCP — somente observação | perfil admin |
| 19 | Troubleshooting transversal | planejada | Pending, BackOff, probes, RBAC, DNS, Route | trilhas anteriores |
| 20 | Desafios integradores | planejada | casos com 6–12 recursos, diagnóstico cego | trilhas anteriores |

Convenções comuns a todas as trilhas: projeto `acNN-<tema>`, rótulo `academy.openshift.dev/managed-by=academia`,
perfil `developer` por padrão, gabaritos em [`solucoes/`](../solucoes/README.md) e limpeza com
`scripts/safe-cleanup.sh`.
