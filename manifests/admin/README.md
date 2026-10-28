# Manifestos de administração (Trilha 17)

Aplicados **como admin** e **só** em projetos `ac17-*` (os de cluster levam `academy.openshift.dev/trilha=17`).

| Arquivo | Objeto | Escopo | Exercício |
|---|---|---|---|
| `quota-completa.yaml` | 3 ResourceQuotas (computação, objetos, escopo BestEffort) | projeto | ADM-003, ADM-004 |
| `limitrange-completo.yaml` | LimitRange com padrões, mínimos, máximos e razão | projeto | ADM-005, ADM-006 |
| `clusterresourcequota-ac17.yaml` | ClusterResourceQuota para projetos rotulados `equipe=ac17` | cluster | ADM-007 |
| `priorityclass-ac17-baixa.yaml` | PriorityClass de valor negativo, sem preempção | cluster | ADM-009 |

Remoção dos objetos de cluster: `oc delete clusterresourcequota,priorityclass -l academy.openshift.dev/trilha=17` (admin).
