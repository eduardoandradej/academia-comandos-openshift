# Kustomize de exemplo (Trilha 13)

Base e dois overlays da aplicação `ac13-loja` (httpd servindo uma página de um ConfigMap gerado).

| Caminho | Conteúdo |
|---|---|
| [`base/`](base/kustomization.yaml) | Deployment, Service, Route e `configMapGenerator` da página; rótulos comuns |
| [`overlays/dev/`](overlays/dev/kustomization.yaml) | namespace `ac13-dev`, rótulo `ambiente: dev`, página própria, variável por JSON patch |
| [`overlays/prod/`](overlays/prod/kustomization.yaml) | namespace `ac13-prod`, 2 réplicas, imagem fixada, recursos e estratégia por patch |

```bash
oc kustomize manifests/kustomize/overlays/dev          # renderiza sem aplicar
oc diff -k manifests/kustomize/overlays/dev            # compara com o cluster
oc apply -k manifests/kustomize/overlays/dev           # aplica (o namespace vem do overlay)
```

Não use `-n` com overlays que já definem `namespace` (TS-040). Copie para `/tmp/ac13` antes de editar.
