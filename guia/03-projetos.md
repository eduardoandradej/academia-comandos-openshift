# Guia direto 03 — Projetos e metadados

> Perfil: `developer` (seções marcadas como admin: `export KUBECONFIG=$HOME/.kube/ac-admin.kubeconfig`).
> Projeto de treino: `ac03-projetos`. Exercícios completos: [trilhas/03-projetos](../trilhas/03-projetos/README.md).

## 1. Project × Namespace — Leitura

```bash
oc get projects
oc get namespaces                 # developer: Forbidden
oc auth can-i list projects       # yes
oc auth can-i list namespaces     # no
```

| | `projects` | `namespaces` |
|---|---|---|
| O que é | visão do OpenShift sobre o namespace | objeto do Kubernetes |
| Quem lista | qualquer usuário (vê só os seus) | só quem tem permissão de cluster |

## 2. Criar projeto e namespace — Altera

```bash
# developer
oc new-project ac03-projetos --display-name='Academia 03 - Projetos' --description='Trilha 03'
oc get project ac03-projetos -o jsonpath='{.metadata.annotations}' | jq .

# admin: namespace puro, já com o rótulo da Academia
oc create namespace ac03-extra --dry-run=client -o yaml \
  | oc label --local -f - academy.openshift.dev/managed-by=academia -o yaml \
  | oc apply -f -
```

| Comando | Quem | O que acontece |
|---|---|---|
| `oc new-project` | developer | cria o projeto; o criador vira admin dele; grava `openshift.io/requester` |
| `oc create namespace` | admin | cria só o namespace, sem dono |
| `--dry-run=client -o yaml \| oc label --local -f - ... \| oc apply -f -` | — | gera o YAML, coloca o rótulo e aplica; pode repetir sem erro |

## 3. Rótulos (labels) — Altera (só no projeto de treino)

```bash
oc create configmap ac03-rotulos --from-literal=x=1 -n ac03-projetos
oc label configmap/ac03-rotulos ambiente=treino -n ac03-projetos
oc label configmap/ac03-rotulos ambiente=revisao --overwrite -n ac03-projetos
oc label configmap/ac03-rotulos camada=dados versao=v1 -n ac03-projetos
oc label configmap/ac03-rotulos versao- -n ac03-projetos
oc label configmap/ac03-rotulos --list -n ac03-projetos
oc get configmap ac03-rotulos -n ac03-projetos --show-labels
```

| Comando | O que faz |
|---|---|
| `oc label <obj> chave=valor` | adiciona |
| `--overwrite` | troca um valor que já existe (sem ela, dá erro) |
| `chave-` | remove |
| `--list` | lista os rótulos do objeto |

Regras: até 63 caracteres; só letras, números, `-`, `_`, `.`; **sem acentos nem espaços**.

## 4. Rótulos em lote — Altera

```bash
oc get configmap -n ac03-projetos -l camada=dados -o name                        # 1. ver quem será afetado
oc label configmap -l camada=dados revisado=sim -n ac03-projetos --dry-run=server # 2. simular
oc label configmap -l camada=dados revisado=sim -n ac03-projetos                  # 3. aplicar
oc label configmap -l revisado=sim revisado- -n ac03-projetos                     # remover em lote
```

Sempre liste e simule antes de alterar vários objetos.

## 5. Anotações (annotations) — Altera

```bash
oc annotate configmap/ac03-rotulos academy.openshift.dev/autor=estudante -n ac03-projetos
oc annotate configmap/ac03-rotulos academy.openshift.dev/autor=revisor --overwrite -n ac03-projetos
oc annotate configmap/ac03-rotulos --list -n ac03-projetos
oc annotate configmap/ac03-rotulos academy.openshift.dev/autor- -n ac03-projetos
```

| | Rótulo | Anotação |
|---|---|---|
| Filtrar com `-l` | sim | **não** |
| Valor | curto, restrito | texto livre |
| Para que serve | agrupar e selecionar | descrever, registrar informação |

## 6. Rótulos recomendados — Altera

```bash
oc create service clusterip loja-api --tcp=8080:8080 -n ac03-projetos
oc label svc/loja-api app.kubernetes.io/name=loja app.kubernetes.io/component=api app.kubernetes.io/part-of=academia -n ac03-projetos
oc get svc -n ac03-projetos -l app.kubernetes.io/name=loja -L app.kubernetes.io/component
```

| Rótulo | Significado |
|---|---|
| `app.kubernetes.io/name` | nome da aplicação |
| `app.kubernetes.io/instance` | qual instância |
| `app.kubernetes.io/component` | papel (frontend, api, banco) |
| `app.kubernetes.io/part-of` | sistema maior (a Console agrupa por ele) |

## 7. O que o OpenShift coloca no namespace — Leitura (admin)

```bash
oc get namespace ac03-projetos -o json | jq '.metadata.labels'
oc get namespace ac03-projetos -o jsonpath='{.metadata.annotations.openshift\.io/sa\.scc\.uid-range}{"\n"}'
```

| Metadado | Para que serve |
|---|---|
| `openshift.io/sa.scc.uid-range` | faixa de UIDs dos pods do projeto (por isso o UID é "estranho") |
| `pod-security.kubernetes.io/*` | nível de segurança aplicado aos pods |

Apenas leia; não altere.

## 8. Seletores ligam objetos — Altera (pods de treino)

```bash
oc apply -f manifests/apps-exemplo/observacao-httpd.yaml -n ac03-projetos
oc get svc obs-web -n ac03-projetos -o jsonpath='{.spec.selector}{"\n"}'
oc describe svc obs-web -n ac03-projetos | grep Endpoints
POD=$(oc get pods -n ac03-projetos -l app=obs-web -o name | head -1)
oc label "$POD" app=depuracao --overwrite -n ac03-projetos   # tira o pod do Service
oc get pods -n ac03-projetos -L app                           # o Deployment cria outro pod
oc delete pod -l app=depuracao -n ac03-projetos               # apaga o pod isolado
```

O Service e o Deployment encontram os pods **pelo rótulo**. Mudou o rótulo, o pod sai do tráfego e o Deployment repõe outro.

## 9. Quem é dono de quem (ownerReferences) — Leitura

```bash
POD=$(oc get pods -n ac03-projetos -l app=obs-web -o name | head -1)
RS=$(oc get "$POD" -n ac03-projetos -o jsonpath='{.metadata.ownerReferences[0].name}')
oc get rs "$RS" -n ac03-projetos -o jsonpath='{.metadata.ownerReferences[0].kind}/{.metadata.ownerReferences[0].name}{"\n"}'
```

Cadeia: **Pod → ReplicaSet → Deployment**. Apagou o dono, os dependentes são apagados juntos.

| `oc delete ... --cascade=` | Efeito |
|---|---|
| `background` (padrão) | apaga o dono e, em seguida, os dependentes |
| `foreground` | espera os dependentes sumirem antes |
| `orphan` | apaga só o dono; os dependentes ficam |

## 10. Exclusão em duas fases (finalizers) — Leitura

```bash
oc get project ac03-projetos -o jsonpath='{.spec.finalizers}{"\n"}'
oc get project ac03-projetos -o jsonpath='{.status.phase} {.metadata.deletionTimestamp}{"\n"}'
```

1. Ao apagar, o objeto recebe `deletionTimestamp` e fica `Terminating`.
2. Quando cada finalizer termina a limpeza, o objeto some.

**Nunca** remova finalizers à mão.

## 11. Versões do objeto — Leitura

```bash
oc get deployment obs-web -n ac03-projetos -o jsonpath='uid={.metadata.uid} rv={.metadata.resourceVersion} gen={.metadata.generation} obs={.status.observedGeneration}{"\n"}'
```

| Campo | Muda quando |
|---|---|
| `uid` | nunca (só em objeto novo) |
| `resourceVersion` | qualquer alteração |
| `generation` | alteração no `spec` |
| `observedGeneration` | o controlador processou a alteração (igual a `generation` = em dia) |

## 12. Encerrar a trilha — Altera

```bash
oc delete project ac03-projetos                  # developer
oc delete project ac03-extra                     # admin
oc get project ac03-projetos ac03-extra          # até NotFound
```
