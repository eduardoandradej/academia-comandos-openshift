#!/usr/bin/env bash
# sim-01-limpa.sh — remove os projetos ac-sim-* do Simulado 01 e lista as reversões manuais de cluster.
#
# Executar em: student@ocp-admin.
# Impacto:     padrão = LEITURA (simulação). Com --execute = apaga os projetos ac-sim-* criados por você
#              (anotação openshift.io/requester), depois de você digitar "sim-01".
#              Objetos de CLUSTER (OAuth, papéis de cluster, grupos, modelo de projeto, operador) NÃO são
#              tocados: o script só imprime o roteiro manual de reversão (VERMELHO).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/scripts/lib/common.sh"

PROJETOS="ac-sim-vitrine ac-sim-painel ac-sim-cofre ac-sim-raiz ac-sim-memoria ac-sim-dados ac-sim-cliente ac-sim-intruso
ac-sim-norte ac-sim-sul ac-sim-leste ac-sim-oeste ac-sim-centro ac-sim-pacotes ac-sim-rotina ac-sim-modelo"
EXECUTE=0
CONFIRM=""

usage() { echo "Uso: sim-01-limpa.sh [--execute] [--confirm sim-01]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute) EXECUTE=1 ;;
    --confirm) CONFIRM="${2:-}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

ac_have oc || ac_die "comando oc não encontrado"
eu="$(oc whoami 2>/dev/null)" || ac_die "sem sessão no cluster"

ac_title "Projetos do simulado"
alvo=""
for p in $PROJETOS; do
  ac_ns_valid "$p" || ac_die "nome fora do padrão da Academia: $p"
  if ! oc get project "$p" >/dev/null 2>&1; then continue; fi
  dono="$(oc get project "$p" -o jsonpath='{.metadata.annotations.openshift\.io/requester}' 2>/dev/null || true)"
  if [[ "$dono" == "$eu" || "$dono" == developer ]]; then
    ac_info "$p (criado por $dono)"; alvo="$alvo $p"
  else
    ac_warn "$p criado por '${dono:-?}': não será apagado por este script"
  fi
done
[[ -n "$alvo" ]] || ac_info "nenhum projeto do simulado encontrado"

if [[ "$EXECUTE" -eq 1 && -n "$alvo" ]]; then
  if [[ -z "$CONFIRM" ]]; then read -r -p 'Digite sim-01 para apagar os projetos acima: ' CONFIRM; fi
  [[ "$CONFIRM" == sim-01 ]] || ac_die "confirmação diferente de sim-01: nada foi apagado"
  for p in $alvo; do
    helm uninstall loja-sim -n "$p" >/dev/null 2>&1 || true
    oc delete project "$p" --ignore-not-found && ac_ok "$p apagado"
  done
elif [[ -n "$alvo" ]]; then
  ac_info "simulação: nada foi apagado (use --execute)"
fi

ac_title "Reversões de cluster — MANUAIS (VERMELHO, perfil admin)"
cat <<'ROTEIRO'
Rode só o que você fez no simulado, um bloco por vez, conferindo o resultado:

# T14 — modelo de projeto (faça PRIMEIRO, para os próximos projetos voltarem ao normal)
oc patch project.config.openshift.io cluster --type=json -p '[{"op":"remove","path":"/spec/projectRequestTemplate"}]'
oc delete template academia-modelo-projeto -n openshift-config

# T02 — papéis de cluster
oc adm policy remove-cluster-role-from-user cluster-admin sim-davi
oc adm policy remove-cluster-role-from-user self-provisioner sim-elisa
# se você tirou o grupo do binding padrão: devolva o grupo e reative a autoatualização
oc patch clusterrolebinding self-provisioners --type=json \
  -p '[{"op":"add","path":"/subjects","value":[{"apiGroup":"rbac.authorization.k8s.io","kind":"Group","name":"system:authenticated:oauth"}]}]'
oc annotate clusterrolebinding self-provisioners rbac.authorization.kubernetes.io/autoupdate=true --overwrite
oc auth can-i create projectrequests --as=developer --as-group=system:authenticated:oauth   # yes

# T04 — grupos
oc delete group sim-coordenacao sim-operacao --ignore-not-found

# T15 — operador (só se você o instalou de fato)
oc delete subscription.operators.coreos.com --all -n cert-manager-operator
oc delete csv --all -n cert-manager-operator
oc delete project cert-manager-operator cert-manager --ignore-not-found

# T01 — provedor e usuários (veja docs/12 para a técnica de backup)
i=$(oc get oauth cluster -o json | jq '.spec.identityProviders | map(.name) | index("academia-simulado")')
[ "$i" != null ] && oc patch oauth cluster --type=json -p "[{\"op\":\"remove\",\"path\":\"/spec/identityProviders/$i\"}]"
oc delete secret academia-simulado-htpasswd -n openshift-config --ignore-not-found
for u in sim-ana sim-bruno sim-carla sim-davi sim-elisa; do
  oc delete user "$u" --ignore-not-found; oc delete identity "academia-simulado:$u" --ignore-not-found
done

# Local
rm -rf ~/sim-01
ROTEIRO
