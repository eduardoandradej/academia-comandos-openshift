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

Imagens: `registry.access.redhat.com/ubi9/httpd-24` — **REQUER PREPARAÇÃO** (acesso de saída do cluster ao registry).
