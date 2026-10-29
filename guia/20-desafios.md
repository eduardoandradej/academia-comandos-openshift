# Guia direto 20 — Desafios integradores

> Perfil: `developer`. Projetos `ac20-*`. Aqui não há comando novo: são **missões** com requisitos, e a validação é
> sua (autoavaliação, sem nota). Missões completas: [trilhas/20-desafios](../trilhas/20-desafios/README.md).

## 1. Como uma missão funciona

1. Leia os requisitos e marque o horário (`date +%T`).
2. Cumpra-os com o que aprendeu; consulte os guias anteriores se precisar.
3. Rode a validação da missão: cada linha deve dizer `OK`.
4. Só então abra o gabarito — ele mostra **uma** solução.

A função de verificação usada em todas as missões:

```bash
ok() { if eval "$2" >/dev/null 2>&1; then echo "OK   $1"; else echo "FALHA $1"; fi; }
ok "loja pronta" "[ \"\$(oc get deploy loja -n ac20-loja -o jsonpath='{.status.readyReplicas}')\" = 2 ]"
```

## 2. O mapa das missões

| Missão | O que entrega | Guias de apoio |
|---|---|---|
| 1 | loja completa: ConfigMap, Deployment, probes, Service, Route edge | [05](05-deployments.md), [07](07-rotas.md), [08](08-config.md) |
| 2 | SA própria, Secret como arquivo 0400, sem Secret em env | [08](08-config.md), [15](15-rbac.md) |
| 3 | entrada só do router e do projeto; saída só DNS | [16](16-rede.md) |
| 4 | rollout sem queda, preStop, PDB, HPA 1–2 | [11](11-resiliencia.md) |
| 5 | promoção e volta com `oc tag` e gatilho | [10](10-imagens.md) |
| 6 | base + overlays dev/prod | [13](13-kustomize.md) |
| 7 | chart com schema e teste; `--atomic`; rollback | [14](14-helm.md) |
| 8 | matriz de acesso de três perfis | [15](15-rbac.md) |
| 9 | CronJob suspenso, Job manual, falha clara | [05](05-deployments.md), [16](16-rede.md) |
| 10 | StatefulSet com PVC por réplica (REQUER PREPARAÇÃO) | [09](09-storage.md) |
| 11 | caso cego com sete defeitos | [19](19-troubleshooting.md) |
| 12 | três casos simultâneos | [19](19-troubleshooting.md) |
| 13 | auditoria com relatório | [17](17-admin.md), [19](19-troubleshooting.md) |
| 14 | exportar, limpar e recriar em outro projeto | [12](12-declarativo.md) |
| 15 | simulado de 2 h com dez tarefas e limpeza total | todos |

## 3. O caso cego da missão 11

```bash
oc new-project ac20-cego
oc apply -f manifests/casos/desafio-11.yaml -n ac20-cego     # não leia o arquivo
triagem ac20-cego                                             # função do guia 19
```

Cada correção muda o sintoma. Anote **andar → defeito → evidência → correção**.

## 4. Armadilhas das missões

| Sintoma | Causa | Cenário |
|---|---|---|
| HTTPS ok, HTTP 503 | Route edge sem `insecureEdgeTerminationPolicy` | [TS-061](../cenarios/troubleshooting/TS-061.md) |
| Deployment 0/1 sem pods | SA não migrada; erro no ReplicaSet | [TS-062](../cenarios/troubleshooting/TS-062.md) |
| Job expira após isolar a rede | política de saída vale para todo pod | [TS-063](../cenarios/troubleshooting/TS-063.md) |

## 5. Encerrar a Academia

```bash
for p in $(oc get projects -o name | grep 'ac20-' | cut -d/ -f2); do
  helm uninstall loja -n "$p" 2>/dev/null || true
  oc delete project "$p" --ignore-not-found
done
rm -rf /tmp/ac20 /tmp/ac20-*
oc get projects | grep -E '^ac[0-9]{2}-' || echo "nenhum projeto de treino restante"
```
