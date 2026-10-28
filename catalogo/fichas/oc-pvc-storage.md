# Ficha: PVC, PV e StorageClass: criar, montar e diagnosticar

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL (PVC) · LEITURA (PV, SC) · **Perfil mínimo:** developer (PVC); admin (PV, SC) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [STO-006](../../trilhas/09-storage/exercicios/STO-006.md), [STO-007](../../trilhas/09-storage/exercicios/STO-007.md), [STO-008](../../trilhas/09-storage/exercicios/STO-008.md), [STO-010](../../trilhas/09-storage/exercicios/STO-010.md), [STO-012](../../trilhas/09-storage/exercicios/STO-012.md), [STO-013](../../trilhas/09-storage/exercicios/STO-013.md)

## Quando usar

Para dar a uma aplicação armazenamento que sobrevive aos pods, e para descobrir por que um volume não liga ou não monta.

## Forma canônica

```bash
oc get pvc -n ac09-storage
```

## Sintaxe

```text
oc get storageclass | sc [-o yaml]
oc get pv [-o custom-columns=...]            # admin
oc get pvc -n NS ; oc describe pvc NOME -n NS
oc set volume deploy/NOME --add --type=pvc --claim-name=PVC [--claim-size=S --claim-mode=rwo|rwm|rom --claim-class=SC] --mount-path=/p
oc patch pvc NOME --type=merge -p '{"spec":{"resources":{"requests":{"storage":"1Gi"}}}}'
```

## Exemplos no HomeLab

```bash
oc get storageclass
oc apply -f pvc.yaml -n ac09-storage
oc get pvc ac09-dados -n ac09-storage -o jsonpath='{.status.phase} {.spec.volumeName}{"\n"}'
oc set volume deployment/ac09-app --add --name=dados --type=pvc --claim-name=ac09-dados --mount-path=/dados -n ac09-storage
oc describe pvc ac09-dados -n ac09-storage | sed -n '/Events:/,$p'
oc get pv -o custom-columns=PV:.metadata.name,STATUS:.status.phase,PVC:.spec.claimRef.name   # admin
```

## Flags principais

| Campo / flag | Efeito |
|---|---|
| `accessModes` | RWO (um nó), RWX (vários nós), ROX, RWOP (um pod) |
| `storageClassName` | classe dinâmica ou rótulo de ligação com PV estático (`""` = sem classe) |
| `resources.requests.storage` | tamanho mínimo |
| `selector` | escolher PV estático por rótulo |
| `--claim-size`/`--claim-mode`/`--claim-class` | `oc set volume` cria o PVC se não existir |

## Comparação com comandos próximos

| | `emptyDir` | PVC |
|---|---|---|
| Vive até | o pod ser removido | o PVC ser apagado (e a política do PV) |
| Precisa de storage no cluster | não | sim (REQUER PREPARAÇÃO no HomeLab) |
| Compartilhado entre réplicas | não | sim, conforme o modo de acesso |
| Uso | cache, temporários, troca entre contêineres | dados da aplicação |

## Antes e depois

Antes de criar: `oc describe quota` (PVCs e `requests.storage`) e `oc get sc`. Depois: `Bound` e `Used By` no `describe pvc`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME         STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
ac09-dados   Bound    ac09-pv-01   1Gi        RWO,RWX        ac09-nfs       2m
```

## Erros comuns

- `exceeded quota ... persistentvolumeclaims=0`: baseline da Academia; veja a preparação (TS-028).
- `Pending` + `no persistent volumes available ... no storage class is set`: sem classe padrão e sem PV compatível (TS-028).
- `Permission denied` ao gravar: permissões do servidor NFS para o UID arbitrário (STO-008).
- `field can not be less than previous value`: PVC não diminui (STO-012).
- PV `Released` após apagar o PVC: política `Retain`; reciclagem pelo admin (STO-015).

## Ajuda e documentação

```bash
oc explain persistentvolumeclaim.spec
oc explain persistentvolume.spec
oc set volume --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc delete pvc <nome>` (dados: conforme a política do PV); remova a montagem com `oc set volume --remove`.
