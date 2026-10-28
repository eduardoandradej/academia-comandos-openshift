#!/usr/bin/env bash
# status.sh — resumo SOMENTE LEITURA dos projetos e recursos da Academia.
#
# Executar em: student@ocp-admin
# Impacto:     LEITURA. Lista apenas nomes e contagens; nunca exibe dados de Secrets.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Tipos procurados pelo rótulo da Academia (somente nomes são listados).
TYPES="deployments,replicasets,pods,services,routes,configmaps,secrets,serviceaccounts,jobs,cronjobs,networkpolicies,persistentvolumeclaims,horizontalpodautoscalers,poddisruptionbudgets,imagestreams"

NS=""

usage() {
  cat <<EOF
Uso: status.sh [-n NAMESPACE]

Sem argumentos: lista os projetos de laboratório (ac-* / acNN-*) visíveis
para a identidade atual e quantos recursos rotulados cada um contém.

Com -n: detalha o namespace indicado — recursos com o rótulo
$ACADEMY_LABEL, ResourceQuota e LimitRange.

Opções:
  -n, --namespace NS   Namespace de laboratório a detalhar.
  -h, --help           Mostra esta ajuda.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--namespace) [[ $# -ge 2 ]] || ac_die "-n exige um namespace"; NS="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; ac_die "opção desconhecida: $1" ;;
  esac
done

ac_have oc || ac_die "oc não encontrado no PATH"

user="$(ac_oc whoami 2>/dev/null)" || ac_die "sem sessão válida (oc whoami falhou)"
ac_info "identidade: $user | servidor: $(ac_oc whoami --show-server 2>/dev/null || echo '?')"

count_labeled() {
  ac_oc get "$TYPES" -n "$1" -l "$ACADEMY_LABEL" -o name --ignore-not-found 2>/dev/null | grep -c . || true
}

if [[ -z "$NS" ]]; then
  ac_title "Projetos de laboratório"
  found=0
  while read -r p; do
    p="${p#project.project.openshift.io/}"
    if [[ -z "$p" ]] || ! ac_ns_valid "$p"; then continue; fi
    found=$((found + 1))
    printf '  %-32s %s recurso(s) rotulado(s)\n' "$p" "$(count_labeled "$p")"
  done < <(ac_oc get projects -o name 2>/dev/null || true)
  [[ "$found" -gt 0 ]] || ac_info "nenhum projeto de laboratório encontrado"
  exit 0
fi

ac_ns_valid "$NS" || ac_die "'$NS' não é um namespace de laboratório (esperado ac-* ou acNN-*)"

ac_title "Recursos rotulados em $NS ($ACADEMY_LABEL)"
ac_oc get "$TYPES" -n "$NS" -l "$ACADEMY_LABEL" -o name --ignore-not-found || true

ac_title "Recursos SEM o rótulo da Academia em $NS (não serão limpos automaticamente)"
ac_oc get deployments,pods,services,routes,configmaps -n "$NS" -l "!$ACADEMY_LABEL_KEY" -o name --ignore-not-found 2>/dev/null \
  | grep -v -E '^configmap/(kube-root-ca\.crt|openshift-service-ca\.crt)$' || ac_info "nenhum"

ac_title "Cotas e limites em $NS"
ac_oc describe resourcequota -n "$NS" 2>/dev/null || ac_info "nenhuma ResourceQuota visível"
ac_oc get limitrange -n "$NS" 2>/dev/null || true
