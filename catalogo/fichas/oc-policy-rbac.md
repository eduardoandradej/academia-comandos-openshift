# Ficha: `oc policy`, `oc create role/rolebinding`, `oc adm groups`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL (projeto) · VERMELHO (cluster) · **Perfil mínimo:** developer no projeto; admin para grupos e ClusterRoles · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [RBC-003](../../trilhas/15-rbac/exercicios/RBC-003.md), [RBC-004](../../trilhas/15-rbac/exercicios/RBC-004.md), [RBC-005](../../trilhas/15-rbac/exercicios/RBC-005.md), [RBC-006](../../trilhas/15-rbac/exercicios/RBC-006.md), [RBC-007](../../trilhas/15-rbac/exercicios/RBC-007.md), [RBC-010](../../trilhas/15-rbac/exercicios/RBC-010.md), [RBC-014](../../trilhas/15-rbac/exercicios/RBC-014.md)

## Quando usar

Para conceder, restringir e auditar quem pode fazer o quê em um projeto, sempre com o menor privilégio.

## Forma canônica

```bash
oc policy add-role-to-user view -z ac15-leitor -n ac15-rbac
```

## Sintaxe

```text
oc policy add-role-to-user|remove-role-from-user PAPEL (USUÁRIO | -z SA) -n NS
oc policy add-role-to-group|remove-role-from-group PAPEL GRUPO -n NS
oc create role NOME --verb=... --resource=... [--resource-name=...] -n NS
oc create rolebinding NOME (--role=R | --clusterrole=CR) (--user=U | --group=G | --serviceaccount=NS:SA) -n NS
oc adm groups new|add-users|remove-users GRUPO [usuários]   (admin)
oc adm policy who-can VERBO RECURSO -n NS ; oc create token SA --duration=10m
```

## Exemplos no HomeLab

```bash
oc auth can-i --list -n ac15-rbac --as=system:serviceaccount:ac15-rbac:ac15-leitor
oc policy add-role-to-user view -z ac15-leitor -n ac15-rbac
oc create role ac15-leitor-pods --verb=get,list,watch --resource=pods,pods/log -n ac15-rbac
oc create rolebinding ac15-robo-pods --role=ac15-leitor-pods --serviceaccount=ac15-rbac:ac15-robo -n ac15-rbac
oc adm groups new ac15-equipe && oc policy add-role-to-group edit ac15-equipe -n ac15-alheio
oc adm policy who-can get secrets -n ac15-rbac
oc adm policy add-cluster-role-to-user view developer --dry-run=client -o yaml     # só para ver: VERMELHO
```

## Flags principais

| Flag | Efeito |
|---|---|
| `-z SA` | sujeito é uma service account do projeto |
| `--resource-name` | restringe a objetos específicos (não vale para `list`/`watch`) |
| `--role` × `--clusterrole` | papel do projeto ou molde de cluster (ambos valem só no NS do RoleBinding) |
| `--as` / `--as-group` | testa como outra identidade (SA do projeto; usuários só como admin) |
| `--dry-run=client -o yaml` | mostra o binding sem criar |

## Comparação com comandos próximos

| Papel | Lê | Altera | RBAC | Secrets |
|---|---|---|---|---|
| `view` | sim | não | não | não |
| `edit` | sim | sim | não | sim |
| `admin` | sim | sim | sim | sim |

## Antes e depois

Antes de conceder: `oc auth can-i ... --as=<sujeito>`. Depois: a mesma pergunta deve mudar de `no` para `yes`, e só ela.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
ROLE                     SUBJECTS
ClusterRole/view         ServiceAccount:ac15-leitor
Role/ac15-leitor-pods    ServiceAccount:ac15-robo
```

## Erros comuns

- `cannot get resource "pods/log"`: subrecurso fora da regra (TS-046).
- `cannot change roleRef`: crie outro binding (TS-047).
- binding sem efeito: nome de grupo/SA errado no sujeito (TS-048).
- `cannot impersonate resource "users"`: impersonar usuários exige admin (RBC-002).
- `in API group "apps"`: a regra precisa do grupo certo (RBC-014).

## Ajuda e documentação

```bash
oc policy --help
oc create role --help
oc adm policy who-can --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc policy remove-role-from-user`; `oc delete rolebinding/role`; `oc adm groups remove-users`.
