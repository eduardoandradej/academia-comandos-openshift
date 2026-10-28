# Guia direto 09 — Storage

> Perfil: `developer`. Projeto de treino: `ac09-storage`. Seções 6 a 10: **REQUER PREPARAÇÃO**
> ([docs/10-preparacao-storage.md](../docs/10-preparacao-storage.md)). Exercícios completos:
> [trilhas/09-storage](../trilhas/09-storage/README.md).

## 1. Tipos de volume — Leitura

```bash
oc explain pod.spec.volumes | sed -n '1,25p'
oc get pods -n ac08-config -o jsonpath='{range .items[*]}{.metadata.name}{": "}{.spec.volumes[*].name}{"\n"}{end}'
```

| Volume | Os dados vivem até |
|---|---|
| sistema de arquivos do contêiner | o contêiner reiniciar |
| `emptyDir` | o pod ser removido |
| `configMap`/`secret` | o objeto de origem existir |
| `persistentVolumeClaim` | o PVC ser apagado |

`hostPath` é bloqueado pela SCC `restricted-v2` e proibido na Academia.

## 2. emptyDir entre contêineres — Altera

```bash
oc new-project ac09-storage
oc apply -f manifests/apps-exemplo/emptydir-compartilhado.yaml -n ac09-storage
oc wait --for=condition=Ready pod/ac09-compartilhado -n ac09-storage --timeout=120s
oc exec ac09-compartilhado -c web -n ac09-storage -- cat /var/www/html/index.html
```

O contêiner `gerador` escreve a página; o `web` (httpd) serve o mesmo volume. Os dois enxergam os mesmos arquivos.

## 3. emptyDir em um Deployment — Altera

```bash
oc create deployment ac09-app --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac09-storage
oc set volume deployment/ac09-app --add --name=cache --type=emptyDir --mount-path=/cache -n ac09-storage
oc rollout status deployment/ac09-app -n ac09-storage
oc exec deploy/ac09-app -n ac09-storage -- sh -c 'date > /cache/marca.txt'
oc rollout restart deployment/ac09-app -n ac09-storage && oc rollout status deployment/ac09-app -n ac09-storage
oc exec deploy/ac09-app -n ac09-storage -- ls /cache        # vazio: pod novo, volume novo
```

| Evento | `emptyDir` |
|---|---|
| contêiner reinicia | mantém os dados |
| pod novo (rollout, delete, nova revisão) | perde os dados |

## 4. emptyDir em memória — Altera

```bash
oc patch deployment ac09-app -n ac09-storage --type=json -p '[
 {"op":"add","path":"/spec/template/spec/volumes/-","value":{"name":"ram","emptyDir":{"medium":"Memory","sizeLimit":"16Mi"}}},
 {"op":"add","path":"/spec/template/spec/containers/0/volumeMounts/-","value":{"name":"ram","mountPath":"/ram"}}]'
oc exec deploy/ac09-app -n ac09-storage -- df -h /ram       # tmpfs
```

Tudo o que se grava em `medium: Memory` conta como memória do contêiner. Defina sempre `sizeLimit`.

## 5. Armazenamento efêmero e despejo — Altera

```bash
oc set resources deployment/ac09-app --requests=ephemeral-storage=32Mi --limits=ephemeral-storage=64Mi -n ac09-storage
oc apply -f manifests/apps-exemplo/cenario-evicted-efemero.yaml -n ac09-storage
sleep 60; oc get pod ac09-guloso -n ac09-storage -o jsonpath='{.status.reason}: {.status.message}{"\n"}'
oc delete -f manifests/apps-exemplo/cenario-evicted-efemero.yaml -n ac09-storage
```

| Limite | Ao passar dele |
|---|---|
| `limits.memory` | o contêiner é morto (OOMKilled) |
| `limits.ephemeral-storage` ou `sizeLimit` | o pod é **despejado** (Evicted) |

## 6. Inventário e PVC sem criar — Leitura

```bash
oc get storageclass                                   # 0 no HomeLab sem preparação
oc describe quota -n ac09-storage | grep -i persistentvolumeclaims
oc explain persistentvolumeclaim.spec
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ac09-dados
spec:
  accessModes: ["ReadWriteOnce"]   # um nó grava (no SNO: todos os pods)
  storageClassName: ac09-nfs        # opção A; lvms-vg1 na opção B
  resources:
    requests:
      storage: 500Mi
```

`oc apply --dry-run=server -f pvc.yaml -n ac09-storage` testa a quota sem criar nada.

## 7. Primeiro PVC — Altera — REQUER PREPARAÇÃO

```bash
export SC=ac09-nfs        # ou lvms-vg1
oc apply -f pvc.yaml -n ac09-storage
oc set volume deployment/ac09-app --add --name=dados --type=pvc --claim-name=ac09-dados --mount-path=/dados -n ac09-storage
oc rollout status deployment/ac09-app -n ac09-storage
oc get pvc ac09-dados -n ac09-storage                   # Bound
oc exec deploy/ac09-app -n ac09-storage -- sh -c 'date > /dados/marca.txt'
oc delete pod -n ac09-storage -l app=ac09-app
oc exec deploy/ac09-app -n ac09-storage -- cat /dados/marca.txt   # continua lá
```

Atalho: `oc set volume ... --type=pvc --claim-name=X --claim-size=300Mi --claim-class="$SC"` cria o PVC e monta.

## 8. Modos de acesso e estratégia — Altera — REQUER PREPARAÇÃO

| Modo | Quem pode gravar |
|---|---|
| `ReadWriteOnce` | pods de **um nó** (no SNO, todos) |
| `ReadWriteMany` | pods de vários nós (NFS sim, LVMS não) |
| `ReadWriteOncePod` | **um pod** (só CSI, opção B) |

```bash
oc patch deployment ac09-app -n ac09-storage --type=merge -p '{"spec":{"strategy":{"type":"Recreate","rollingUpdate":null}}}'
```

Com PVC RWO, use `Recreate`: em clusters com vários nós, o rolling update pode travar com `Multi-Attach error`.

## 9. Expandir — Altera — REQUER PREPARAÇÃO (opção B)

```bash
oc get storageclass "$SC" -o jsonpath='{.allowVolumeExpansion}{"\n"}'
oc patch pvc ac09-dados -n ac09-storage --type=merge -p '{"spec":{"resources":{"requests":{"storage":"1Gi"}}}}'
oc get pvc ac09-dados -n ac09-storage -o jsonpath='{.status.capacity.storage}{"\n"}'
```

PVC só cresce, nunca diminui.

## 10. StatefulSet — Altera — REQUER PREPARAÇÃO

```bash
sed "s/AC09_SC/$SC/" manifests/apps-exemplo/statefulset-mini.yaml | oc apply -n ac09-storage -f -
oc rollout status statefulset/ac09-sts -n ac09-storage
oc get pods,pvc -n ac09-storage -l app=ac09-sts         # ac09-sts-0/1 e dados-ac09-sts-0/1
```

Cada réplica tem nome estável e o próprio PVC; reduzir réplicas **não** apaga os PVCs.

## 11. Diagnóstico — Leitura

| Sintoma | Causa típica | Cenário |
|---|---|---|
| `exceeded quota ... persistentvolumeclaims=0` | baseline proíbe PVC | [TS-028](../cenarios/troubleshooting/TS-028.md) |
| PVC `Pending` | sem classe padrão / sem PV compatível | [TS-028](../cenarios/troubleshooting/TS-028.md) |
| dados sumiram após deploy | era `emptyDir` | [TS-029](../cenarios/troubleshooting/TS-029.md) |
| pod `Evicted` | passou do `ephemeral-storage` | [TS-030](../cenarios/troubleshooting/TS-030.md) |
| `Permission denied` em `/dados` | permissões do NFS para o UID arbitrário | STO-008 |
| pod `Pending` com `persistentvolumeclaim ... not found` | nome do PVC errado ou outro projeto | STO-014 |

## 12. Encerrar a trilha — Altera

```bash
oc delete project ac09-storage
oc get project ac09-storage      # até NotFound
```

Opção A: PVs ficam `Released` (política `Retain`); o admin limpa os dados e os libera (STO-015).
