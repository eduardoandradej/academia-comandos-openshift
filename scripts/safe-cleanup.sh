#!/usr/bin/env bash
# safe-cleanup.sh — limpeza restrita aos recursos da Academia.
#
# Executar em: student@ocp-admin
# Impacto:     padrão = LEITURA (simulação). Com --execute = MUTAÇÃO LOCAL REVERSÍVEL
#              no namespace de laboratório indicado, após confirmação digitada.
#
# Garantias:
#   * só aceita namespaces ac-* / acNN-*; recusa openshift-*, kube-*, default etc.;
#   * só apaga recursos com rótulo academy.openshift.dev/<chave>=<valor>;
#   * nunca usa --all, -A ou --all-namespaces;
#   * apagar o próprio projeto exige --delete-project e prova de que ele é da Academia.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

TYPES="deployments,replicasets,pods,services,routes,configmaps,secrets,serviceaccounts,jobs,cronjobs,networkpolicies,persistentvolumeclaims,horizontalpodautoscalers,poddisruptionbudgets,imagestreams,rolebindings"

NS=""
LABEL="$ACADEMY_LABEL"
EXECUTE=0
DELETE_PROJECT=0
CONFIRM=""

usage() {
  cat <<EOF
Uso: safe-cleanup.sh -n NAMESPACE [opções]

Por padrão apenas SIMULA: mostra o que seria apagado e não altera nada.

Opções:
  -n, --namespace NS    Namespace de laboratório (obrigatório; ac-* ou acNN-*).
  -l, --selector K=V    Rótulo dos recursos a apagar (padrão: $ACADEMY_LABEL).
                        A chave deve começar com academy.openshift.dev/.
  --execute             Apaga de fato, após você digitar o nome do namespace.
  --delete-project      Com --execute: apaga também o projeto, se ele for da Academia
                        (rótulo $ACADEMY_LABEL no namespace ou criado por você).
  --confirm NS          Confirmação não interativa (deve ser igual a -n).
  -h, --help            Mostra esta ajuda.

Exemplos:
  scripts/safe-cleanup.sh -n ac00-orientacao
  scripts/safe-cleanup.sh -n ac00-orientacao --execute
  scripts/safe-cleanup.sh -n ac00-orientacao --execute --delete-project
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--namespace) [[ $# -ge 2 ]] || ac_die "-n exige um namespace"; NS="$2"; shift 2 ;;
    -l|--selector)  [[ $# -ge 2 ]] || ac_die "-l exige um seletor"; LABEL="$2"; shift 2 ;;
    --execute) EXECUTE=1; shift ;;
    --delete-project) DELETE_PROJECT=1; shift ;;
    --confirm) [[ $# -ge 2 ]] || ac_die "--confirm exige o nome do namespace"; CONFIRM="$2"; shift 2 ;;
    -A|--all|--all-namespaces) ac_die "opção $1 é proibida neste script" ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; ac_die "opção desconhecida: $1" ;;
  esac
done

[[ -n "$NS" ]] || { usage >&2; ac_die "informe o namespace com -n"; }
ac_ns_valid "$NS" || ac_die "'$NS' recusado: apenas namespaces de laboratório ac-* ou acNN-* são aceitos"
[[ "$LABEL" =~ ^academy\.openshift\.dev/[a-z0-9]([-a-z0-9.]*[a-z0-9])?=[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$ ]] \
  || ac_die "seletor '$LABEL' recusado: use exatamente academy.openshift.dev/<chave>=<valor>"
[[ "$DELETE_PROJECT" -eq 0 || "$EXECUTE" -eq 1 ]] || ac_die "--delete-project só é aceito junto com --execute"

ac_have oc || ac_die "oc não encontrado no PATH"
user="$(ac_oc whoami 2>/dev/null)" || ac_die "sem sessão válida (oc whoami falhou)"

if ! ac_oc get project "$NS" -o name >/dev/null 2>&1; then
  ac_info "projeto $NS não existe ou não é visível para $user — nada a limpar"
  exit 0
fi

ac_title "Recursos em $NS com o rótulo $LABEL"
targets="$(ac_oc get "$TYPES" -n "$NS" -l "$LABEL" -o name --ignore-not-found 2>/dev/null || true)"
if [[ -z "$targets" ]]; then
  ac_info "nenhum recurso rotulado encontrado"
else
  while IFS= read -r t; do printf '  - %s\n' "$t"; done <<<"$targets"
fi

project_is_academy() {
  local nslabel requester
  nslabel="$(ac_oc get namespace "$NS" -o "jsonpath={.metadata.labels.academy\.openshift\.dev/managed-by}" 2>/dev/null || true)"
  [[ "$nslabel" == "$ACADEMY_LABEL_VALUE" ]] && return 0
  requester="$(ac_oc get project "$NS" -o "jsonpath={.metadata.annotations.openshift\.io/requester}" 2>/dev/null || true)"
  [[ -n "$requester" && "$requester" == "$user" ]] && return 0
  return 1
}

if [[ "$EXECUTE" -eq 0 ]]; then
  printf '\nSIMULAÇÃO: nada foi apagado. Para apagar, repita com --execute.\n'
  exit 0
fi

if [[ -z "$CONFIRM" ]]; then
  [[ -t 0 ]] || ac_die "sem terminal interativo: use --confirm $NS"
  printf '\nDigite o nome do namespace (%s) para confirmar a exclusão: ' "$NS"
  read -r CONFIRM
fi
[[ "$CONFIRM" == "$NS" ]] || ac_die "confirmação não confere — nada foi apagado"

if [[ -n "$targets" ]]; then
  ac_title "Apagando recursos rotulados em $NS"
  ac_oc delete "$TYPES" -n "$NS" -l "$LABEL" --ignore-not-found --wait=true --timeout=90s
  left="$(ac_oc get "$TYPES" -n "$NS" -l "$LABEL" -o name --ignore-not-found 2>/dev/null || true)"
  if [[ -z "$left" ]]; then ac_ok "nenhum recurso rotulado restante em $NS"; else ac_warn "ainda restam: $(tr '\n' ' ' <<<"$left")"; fi
fi

if [[ "$DELETE_PROJECT" -eq 1 ]]; then
  if project_is_academy; then
    ac_title "Apagando o projeto $NS"
    ac_oc delete project "$NS"
    ac_info "a exclusão é assíncrona: confirme com 'oc get project $NS' até receber NotFound"
  else
    ac_die "projeto $NS não tem o rótulo $ACADEMY_LABEL nem foi solicitado por $user — não será apagado"
  fi
fi
