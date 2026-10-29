# Trilhas

> 21 trilhas progressivas (00 a 20). **Disponíveis:** 00 a 19. As demais são **planejadas**: as pastas só passam a
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
| 10 | [Imagens e registries](10-imagens/README.md) | **disponível** (15) | image info, digest, pull policy, ImageStreams, tag, image-lookup, gatilhos | registry interno desligado (Source) |
| 11 | [Resiliência](11-resiliencia/README.md) | **disponível** (15) | requests/limits, probes, autocura, preStop, rollout sem queda, HPA, PDB | Metrics API (HPA) |
| 12 | [Manifestos declarativos](12-declarativo/README.md) | **disponível** (15) | gerar, validar, apply, diff, 3 vias, SSA, replace, patch, prune | — |
| 13 | [Kustomize e Templates](13-kustomize/README.md) | **disponível** (15) | base, overlays, geradores, images, patches, oc process, new-app --template | — |
| 14 | [Helm](14-helm/README.md) | **disponível** (15) | template, install, upgrade, valores, rollback, test, atomic | cliente `helm` ([docs/11](../docs/11-preparacao-helm.md)) |
| 15 | [Usuários, identidade e RBAC](15-rbac/README.md) | **disponível** (15) | can-i, papéis, Roles, bindings, grupos, tokens, SCC, OAuth (leitura) | perfil admin; HTPasswd opcional ([docs/12](../docs/12-preparacao-usuarios.md)) |
| 16 | [Rede e isolamento](16-rede/README.md) | **disponível** (15) | NetworkPolicy entrada/saída, router, DNS, TLS, service CA | — |
| 17 | [Administração de recursos](17-admin/README.md) | **disponível** (15) | capacidade, quotas, LimitRange, CRQ, prioridade, varredura, node-logs, inspect | perfil admin |
| 18 | [Operadores e manutenção](18-operadores/README.md) | **disponível** (15) | CVO, CO, OLM, CRDs, MCP, atualização e backup planejados, alertas — somente observação | perfil admin |
| 19 | [Troubleshooting transversal](19-troubleshooting/README.md) | **disponível** (15) | método dos 7 andares, triagem, 10 casos multicausa, linha do tempo, pós-incidente | trilhas anteriores |
| 20 | Desafios integradores | planejada | casos com 6–12 recursos, diagnóstico cego | trilhas anteriores |

Convenções comuns a todas as trilhas: projeto `acNN-<tema>`, rótulo `academy.openshift.dev/managed-by=academia`,
perfil `developer` por padrão, gabaritos em [`solucoes/`](../solucoes/README.md) e limpeza com
`scripts/safe-cleanup.sh`.
