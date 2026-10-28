# Manifestos

Todos os manifestos são pequenos, rotulados com `academy.openshift.dev/managed-by=academia` e **sem** o campo
`namespace` — sempre aplique com `-n acNN-<tema>`. Revise com `less`, valide com `--dry-run=server` e compare com
`oc diff` antes de aplicar.

| Arquivo | Conteúdo | Perfil | Usado em |
|---|---|---|---|
| [`baseline-seguro/quota-limitrange.yaml`](baseline-seguro/quota-limitrange.yaml) | ResourceQuota `ac-quota` + LimitRange `ac-limits` dimensionados para o SNO | admin | ORI-012 (e recomendado nas demais trilhas) |
| [`apps-exemplo/observacao-httpd.yaml`](apps-exemplo/observacao-httpd.yaml) | ConfigMap + Deployment `obs-web` (2× httpd UBI 9) + Service | developer | CLI-010, CON-003 em diante, PRJ-008 em diante |
| [`apps-exemplo/cenario-imagem-inexistente.yaml`](apps-exemplo/cenario-imagem-inexistente.yaml) | Deployment com tag inexistente (falha proposital) | developer | TS-009 |
| [`apps-exemplo/cenario-terminacao-lenta.yaml`](apps-exemplo/cenario-terminacao-lenta.yaml) | Pod que ignora SIGTERM (grace period de 90 s) | developer | TS-011 |
| [`apps-exemplo/pod-dois-conteineres.yaml`](apps-exemplo/pod-dois-conteineres.yaml) | Pod com init container, httpd e sidecar | developer | POD-005 em diante |
| [`apps-exemplo/cenario-crashloop.yaml`](apps-exemplo/cenario-crashloop.yaml) | Pod que termina com erro (CrashLoopBackOff) | developer | TS-013, POD-013 |
| [`apps-exemplo/cenario-pending-nodeselector.yaml`](apps-exemplo/cenario-pending-nodeselector.yaml) | Pod com nodeSelector sem nó correspondente | developer | TS-014 |
| [`apps-exemplo/cenario-oomkilled.yaml`](apps-exemplo/cenario-oomkilled.yaml) | Pod que estoura 48 Mi de memória | developer | TS-015 |
| [`apps-exemplo/job-lote.yaml`](apps-exemplo/job-lote.yaml) | Job indexado: 4 conclusões, 2 em paralelo | developer | DEP-010 |
| [`apps-exemplo/daemonset-mini.yaml`](apps-exemplo/daemonset-mini.yaml) | DaemonSet mínimo (1 pod no SNO) | developer | DEP-012 |
| [`apps-exemplo/cenario-job-falha.yaml`](apps-exemplo/cenario-job-falha.yaml) | Job que esgota o backoffLimit | developer | TS-017 |
| [`apps-exemplo/cenario-quota-deploy.yaml`](apps-exemplo/cenario-quota-deploy.yaml) | Deployment que excede `requests.cpu` da quota | developer | TS-018 (exige baseline) |
| [`apps-exemplo/servicos-azul-verde.yaml`](apps-exemplo/servicos-azul-verde.yaml) | Backends httpd `web-azul` e `web-verde` com página própria (ConfigMap) | developer | SVC-001 em diante, RTE-001 em diante |
| [`apps-exemplo/cenario-nao-pronto.yaml`](apps-exemplo/cenario-nao-pronto.yaml) | Deployment + Service com readiness que nunca passa | developer | TS-021 |
| [`apps-exemplo/cenario-config-ausente.yaml`](apps-exemplo/cenario-config-ausente.yaml) | Deployment que referencia ConfigMap e Secret inexistentes | developer | TS-025 |
| [`apps-exemplo/emptydir-compartilhado.yaml`](apps-exemplo/emptydir-compartilhado.yaml) | Pod com dois contêineres trocando arquivos por `emptyDir` | developer | STO-002 |
| [`apps-exemplo/cenario-evicted-efemero.yaml`](apps-exemplo/cenario-evicted-efemero.yaml) | Pod que estoura o `ephemeral-storage` (32 MiB) | developer | STO-005, TS-030 |
| [`apps-exemplo/statefulset-mini.yaml`](apps-exemplo/statefulset-mini.yaml) | StatefulSet com um PVC por réplica (REQUER PREPARAÇÃO) | developer | STO-013 |
| [`apps-exemplo/cenario-liveness-agressiva.yaml`](apps-exemplo/cenario-liveness-agressiva.yaml) | Deployment com liveness mais lenta que o próprio timeout | developer | RES-014, TS-034 |
| [`apps-exemplo/declarativo-app.yaml`](apps-exemplo/declarativo-app.yaml) | aplicação completa (ConfigMap, Deployment, Service, Route) em um arquivo | developer | Trilha 12 |
| [`kustomize/`](kustomize/README.md) | base e overlays `dev`/`prod` da loja `ac13-loja` | developer | Trilha 13 |
| [`templates/ac13-template.yaml`](templates/ac13-template.yaml) | Template do OpenShift com parâmetros e valor gerado | developer | Trilha 13 |
| [`helm/ac14-loja/`](helm/ac14-loja/README.md) | chart Helm de treino (valores, schema, helpers, teste) | developer | Trilha 14 |
| [`networkpolicies/`](networkpolicies/README.md) | políticas de entrada e saída para os projetos `ac16-*` | developer | Trilha 16 |
| [`admin/`](admin/README.md) | quotas, LimitRange, ClusterResourceQuota e PriorityClass de treino | admin | Trilha 17 |
| [`preparacao/storage-nfs-pv.yaml`](preparacao/storage-nfs-pv.yaml) | 3 PVs NFS estáticos (opção A da preparação de storage) | admin | docs/10 |
| [`preparacao/quota-storage-ac09.yaml`](preparacao/quota-storage-ac09.yaml) | quota do `ac09-storage` liberando 3 PVCs / 3Gi | admin | docs/10 |

Imagens: `registry.access.redhat.com/ubi9/httpd-24` — **REQUER PREPARAÇÃO** (acesso de saída do cluster ao registry).
