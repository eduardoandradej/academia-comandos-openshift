# Guia direto 18 — Operadores e manutenção

> Perfil: **`admin`, somente leitura**. Nada nesta página altera a plataforma. Exercícios completos:
> [trilhas/18-operadores](../trilhas/18-operadores/README.md).

## 1. Versão e atualizações — Leitura

```bash
oc get clusterversion
oc get clusterversion version -o json | jq -r '.status.history[] | "\(.state) \(.version) \(.completionTime // "-")"'
oc get clusterversion version -o json | jq -r '(.status.availableUpdates // [])[].version'
oc adm upgrade            # sem argumentos: só exibe o estado
```

`oc adm upgrade --to=...` **inicia** a atualização: nunca pela Academia.

## 2. ClusterOperators — Leitura

```bash
oc get co
oc get co --no-headers | awk '$3!="True" || $4!="False" || $5!="False"'     # fora do ideal
oc describe co monitoring | sed -n '/Conditions:/,/Extension:/p'
```

| Condição | Ideal |
|---|---|
| Available | True |
| Progressing | False (True por alguns minutos após religar o SNO é normal — [TS-055](../cenarios/troubleshooting/TS-055.md)) |
| Degraded | False |
| Upgradeable | True |

## 3. Operador → CR → operand — Leitura

```bash
oc get co ingress -o json | jq -r '.status.relatedObjects[] | "\(.resource) \(.namespace // "-") \(.name)"'
oc get ingresscontroller default -n openshift-ingress-operator
oc get deployment router-default -n openshift-ingress
```

Editar o operand (ex.: o Deployment do router) não adianta: o operador reconcilia e desfaz.

## 4. Campos que não se toca — Leitura

```bash
oc get clusterversion version -o jsonpath='{.spec.overrides}{"\n"}'          # vazio
oc get kubeapiserver cluster -o jsonpath='{.spec.managementState}{"\n"}'     # Managed
```

`Unmanaged`, `Removed`, `unsupportedConfigOverrides` e `overrides` do CVO mudam o suporte e o comportamento do cluster.

## 5. OLM — Leitura

```bash
oc get catalogsources -n openshift-marketplace
oc get packagemanifests -n openshift-marketplace | head
oc get subscriptions,csv,installplan -A
oc get operatorgroups -A
```

| Objeto | Papel |
|---|---|
| Subscription | pacote + canal + catálogo + aprovação (`Automatic`/`Manual`) |
| InstallPlan | o plano; com `Manual`, espera aprovação ([TS-057](../cenarios/troubleshooting/TS-057.md)) |
| CSV | a versão instalada (`Succeeded`) |
| OperatorGroup | namespaces que o operador observa |

Instalar um operador só no papel: `oc apply --dry-run=server -f subscription.yaml -n ac18-ops` (OPS-007).

## 6. CRDs — Leitura

```bash
oc get crd --no-headers | wc -l
oc get crd -o json | jq -r '.items[].spec.group' | sort | uniq -c | sort -rn | head
```

Apagar um CRD apaga todos os objetos daquele tipo: VERMELHO absoluto.

## 7. MachineConfig — Leitura

```bash
oc get mcp
oc get mcp master -o jsonpath='{.status.configuration.name}{"\n"}'
oc get mc --sort-by=.metadata.creationTimestamp | tail -5
```

Um MachineConfig novo **reinicia o nó** — no SNO, o cluster inteiro ([TS-056](../cenarios/troubleshooting/TS-056.md)).

## 8. Manutenção de nó (conceitual)

| Comando | No SNO |
|---|---|
| `oc adm cordon` | nada mais é agendado, nem pods do sistema |
| `oc adm drain` | despeja API, router, DNS: o cluster para |
| reboot | indisponibilidade total |

Todos proibidos na Academia. A manutenção segue a apostila do HomeLab.

## 9. Antes de uma atualização — Leitura

```bash
oc get co -o json | jq -r '.items[] | .metadata.name as $n | .status.conditions[] | select(.type=="Upgradeable" and .status=="False") | $n'
oc get mcp master -o jsonpath='{.status.conditions[?(@.type=="Updated")].status}{"\n"}'
oc get pdb -A -o json | jq '[.items[] | select(.status.disruptionsAllowed==0)] | length'
oc get cm admin-acks -n openshift-config -o jsonpath='{.data}{"\n"}'
```

E, manualmente: backup do etcd, cópia da VM no HD, janela de indisponibilidade, espaço em `/var` do `kvm-server`.

## 10. Alertas pela API — Leitura

```bash
TQ=$(oc get route thanos-querier -n openshift-monitoring -o jsonpath='{.spec.host}')
T=$(oc whoami -t)
curl -sSk -H "Authorization: Bearer $T" "https://$TQ/api/v1/alerts" | jq -r '.data.alerts[] | "\(.labels.severity) \(.labels.alertname)"' | sort | uniq -c
unset T
```

O `Watchdog` sempre dispara: prova que os alertas funcionam. O token fica só na variável.

## 11. Operador degradado: roteiro — Leitura

| # | Passo |
|---|---|
| 1 | condições e mensagem do ClusterOperator |
| 2 | `relatedObjects` (namespaces e recursos) |
| 3 | pods do operador e do operand |
| 4 | eventos `Warning` desses namespaces |
| 5 | `oc logs deploy/<operador> -n <ns>-operator --tail=50` |
| 6 | coleta `oc adm inspect co/<x>` — planejada, com autorização |

Ler é seguro; reiniciar pods ou editar objetos do operador não é.
