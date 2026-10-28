# Manifestos

Todos os manifestos são pequenos, rotulados com `academy.openshift.dev/managed-by=academia` e **sem** o campo
`namespace` — sempre aplique com `-n acNN-<tema>`. Revise com `less`, valide com `--dry-run=server` e compare com
`oc diff` antes de aplicar.

| Arquivo | Conteúdo | Perfil | Usado em |
|---|---|---|---|
| [`baseline-seguro/quota-limitrange.yaml`](baseline-seguro/quota-limitrange.yaml) | ResourceQuota `ac-quota` + LimitRange `ac-limits` dimensionados para o SNO | admin | ORI-012 (e recomendado nas demais trilhas) |
| [`apps-exemplo/observacao-httpd.yaml`](apps-exemplo/observacao-httpd.yaml) | ConfigMap + Deployment `obs-web` (2× httpd UBI 9) + Service | developer | CLI-010, CON-003 em diante |
| [`apps-exemplo/cenario-imagem-inexistente.yaml`](apps-exemplo/cenario-imagem-inexistente.yaml) | Deployment com tag inexistente (falha proposital) | developer | TS-009 |

Imagens: `registry.access.redhat.com/ubi9/httpd-24` — **REQUER PREPARAÇÃO** (acesso de saída do cluster ao registry).
