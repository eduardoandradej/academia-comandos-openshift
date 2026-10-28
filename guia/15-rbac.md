# Guia direto 15 — Usuários, identidade e RBAC

> Perfis: `developer` (padrão) e `admin` (onde indicado). Projeto de treino: `ac15-rbac`. As permissões são testadas
> com service accounts e `--as`, sem criar usuários. Exercícios completos: [trilhas/15-rbac](../trilhas/15-rbac/README.md).

## 1. Quem sou e o que posso — Leitura

```bash
oc whoami; oc auth whoami
oc auth can-i create deployments -n ac15-rbac
oc auth can-i --list -n ac15-rbac | head
```

`developer` cria projetos porque o grupo `system:authenticated:oauth` tem o papel `self-provisioner`.

## 2. Perguntar por outra identidade — Leitura

```bash
oc new-project ac15-rbac
oc create serviceaccount ac15-leitor -n ac15-rbac
S=system:serviceaccount:ac15-rbac:ac15-leitor
oc auth can-i get pods -n ac15-rbac --as=$S
oc auth can-i get pods/log -n ac15-rbac --as=$S        # subrecurso: pergunta separada
```

| Forma | Exemplo |
|---|---|
| subrecurso | `pods/log`, `pods/exec`, `deployments/scale` |
| objeto específico | `get configmap/ac15-publico` |
| outra identidade | `--as=system:serviceaccount:NS:SA` (usuários: só como admin) |

## 3. Papéis padrão — Altera

```bash
oc policy add-role-to-user view -z ac15-leitor -n ac15-rbac
oc policy add-role-to-user edit -z ac15-leitor -n ac15-rbac
oc policy remove-role-from-user edit -z ac15-leitor -n ac15-rbac
oc get rolebindings -n ac15-rbac -o wide
```

| Papel | Lê | Altera | Gerencia RBAC | Lê Secrets |
|---|---|---|---|---|
| `view` | sim | não | não | não |
| `edit` | sim | sim | não | sim |
| `admin` | sim | sim | sim | sim |

## 4. Role mínima — Altera

```bash
oc create role ac15-leitor-pods --verb=get,list,watch --resource=pods,pods/log -n ac15-rbac
oc create role ac15-so-publico --verb=get --resource=configmaps --resource-name=ac15-publico -n ac15-rbac
oc create rolebinding ac15-robo-pods --role=ac15-leitor-pods --serviceaccount=ac15-rbac:ac15-robo -n ac15-rbac
```

Verbos explícitos, subrecursos um a um, `--resource-name` para objetos específicos (não vale para `list`).

## 5. RoleBinding por dentro — Leitura

```yaml
subjects:                # QUEM: User, Group ou ServiceAccount
  - kind: ServiceAccount
    name: ac15-robo
    namespace: ac15-rbac
roleRef:                 # O QUÊ: Role do projeto ou ClusterRole (imutável!)
  kind: ClusterRole
  name: view
```

Para trocar o papel: crie um binding novo e só então apague o antigo ([TS-047](../cenarios/troubleshooting/TS-047.md)).

## 6. ClusterRole em um projeto — Altera (admin)

```bash
ac-admin
oc create clusterrole ac15-leitor-configmaps --verb=get,list,watch --resource=configmaps
oc label clusterrole ac15-leitor-configmaps academy.openshift.dev/managed-by=academia academy.openshift.dev/trilha=15
ac-dev
oc create rolebinding ac15-robo-cm --clusterrole=ac15-leitor-configmaps --serviceaccount=ac15-rbac:ac15-robo -n ac15-rbac
```

| Binding | Vale em |
|---|---|
| RoleBinding → Role ou ClusterRole | **um** projeto |
| ClusterRoleBinding → ClusterRole | **o cluster todo** (VERMELHO: só `--dry-run` na Academia) |

## 7. Grupos — Altera (admin)

```bash
ac-admin
oc adm groups new ac15-equipe
oc label group ac15-equipe academy.openshift.dev/managed-by=academia academy.openshift.dev/trilha=15
oc policy add-role-to-group edit ac15-equipe -n ac15-alheio
oc adm groups add-users ac15-equipe developer
oc auth can-i create deployments -n ac15-alheio --as=developer
oc adm groups remove-users ac15-equipe developer
ac-dev
```

A pertença vale na hora (sem novo login). Dê papéis a grupos, não a pessoas.

## 8. Service accounts e tokens — Altera

```bash
T=$(oc create token ac15-leitor -n ac15-rbac --duration=10m)
oc --token="$T" whoami          # system:serviceaccount:ac15-rbac:ac15-leitor
unset T
```

Tokens são senhas: só em variável, nunca em arquivo, tela compartilhada ou repositório.

## 9. Auditoria — Leitura

```bash
oc get rolebindings -n ac15-rbac -o json | jq -r '.items[] | .roleRef.name as $r | .subjects[]? | "\(.kind)\t\(.name)\t\($r)"'
oc adm policy who-can get secrets -n ac15-rbac
```

## 10. SCC é permissão — Leitura

```bash
oc get pod <pod> -n ac15-rbac -o jsonpath='{.metadata.annotations.openshift\.io/scc}{"\n"}'   # restricted-v2
oc auth can-i use scc/anyuid -n ac15-rbac --as=system:serviceaccount:ac15-rbac:default
```

Pod que pede `runAsUser: 0` é recusado. A correção é a imagem, não conceder `anyuid`/`privileged`.

## 11. Ler um Forbidden — Leitura

```text
User "system:serviceaccount:ac15-rbac:ac15-robo" cannot get resource "pods/log" in API group "" in the namespace "ac15-rbac"
      └ quem ┘                                         └ verbo ┘        └ recurso ┘        └ grupo ┘        └ escopo ┘
```

| Sintoma | Causa | Cenário |
|---|---|---|
| lê pods, não logs | falta `pods/log` | [TS-046](../cenarios/troubleshooting/TS-046.md) |
| `cannot change roleRef` | `roleRef` imutável | [TS-047](../cenarios/troubleshooting/TS-047.md) |
| binding existe, acesso não | nome do sujeito errado | [TS-048](../cenarios/troubleshooting/TS-048.md) |
| `at the cluster scope` | recurso de cluster: nenhum RoleBinding resolve | RBC-014 |
| `in API group "apps"` | regra sem o grupo certo | RBC-014 |

## 12. Encerrar a trilha — Altera

```bash
oc delete project ac15-rbac
ac-admin
oc delete project ac15-alheio --ignore-not-found
oc delete groups,clusterroles -l academy.openshift.dev/managed-by=academia,academy.openshift.dev/trilha=15
ac-dev
```
