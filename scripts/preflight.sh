#!/usr/bin/env bash
# preflight.sh — verificação SOMENTE LEITURA do HomeLab OpenShift 4.22 SNO.
#
# Executar em: student@ocp-admin
# Impacto:     LEITURA. Nenhum comando deste script cria, altera ou apaga recursos.
# Segredos:    não lê nem imprime kubeconfig, tokens, pull secret ou senhas.
#
# Códigos de saída: 0 = sem falhas | 1 = há falhas | 2 = erro de uso
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

KVM_SSH=""
MIN_FREE_GIB="${ACADEMY_MIN_FREE_GIB:-20}"

usage() {
  cat <<'EOF'
Uso: preflight.sh [opções]

Verificação somente leitura do HomeLab antes de qualquer exercício.

Opções:
  --kvm-ssh DESTINO   Também consulta o espaço livre de /var no kvm-server via SSH
                      (ex.: --kvm-ssh usuario@192.168.10.25). Só use se você tem
                      acesso autorizado. Executa apenas "df -P -B1G /var".
  --min-free GIB      Margem mínima de espaço livre em /var no host (padrão: 20).
  --no-color          Desativa cores.
  -h, --help          Mostra esta ajuda.

Variáveis: ACADEMY_API_URL (padrão https://api.ocp.example.lab:6443),
           ACADEMY_TIMEOUT (padrão 15s).

Saída: 0 = nenhuma FALHA; 1 = ao menos uma FALHA; 2 = erro de uso.
AVISO e PULADO não geram falha (PULADO = sem permissão ou não aplicável).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kvm-ssh) [[ $# -ge 2 ]] || ac_die "--kvm-ssh exige um destino"; KVM_SSH="$2"; shift 2 ;;
    --min-free) [[ $# -ge 2 && "$2" =~ ^[0-9]+$ ]] || ac_die "--min-free exige um número inteiro"; MIN_FREE_GIB="$2"; shift 2 ;;
    --no-color) ac_no_color; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; ac_die "opção desconhecida: $1" ;;
  esac
done

# Captura saída e erro de um comando oc sem abortar o script.
# Uso: capture VAR_SAIDA VAR_ERRO comando...
OUT=""; ERR=""
capture() {
  local errfile rc=0
  errfile="$(mktemp)"
  OUT="$("$@" 2>"$errfile")" || rc=$?
  ERR="$(cat "$errfile")"
  rm -f "$errfile"
  return "$rc"
}

ac_title "1. Ferramentas locais"
if ac_have oc; then
  ver="$(oc version --client 2>/dev/null | head -n1 || true)"
  case "$ver" in
    *4.22*) ac_ok "oc encontrado: $ver" ;;
    *) ac_warn "oc encontrado, mas versão diferente de 4.22: ${ver:-desconhecida}" ;;
  esac
else
  ac_fail "oc não encontrado no PATH — nada mais pode ser verificado"
  exit 1
fi
for tool in kubectl jq; do
  if ac_have "$tool"; then ac_ok "$tool encontrado"; else ac_warn "$tool não encontrado (alguns exercícios dependem dele)"; fi
done
if ac_have helm; then ac_info "helm encontrado (Trilha 14)"; else ac_info "helm ausente — Trilha 14 REQUER PREPARAÇÃO (docs/11-preparacao-helm.md)"; fi

ac_title "2. Kubeconfig (sem ler o conteúdo)"
if [[ -z "${KUBECONFIG:-}" ]]; then
  ac_info "KUBECONFIG não definido: o oc usa ~/.kube/config"
  kc_list="$HOME/.kube/config"
else
  ac_info "KUBECONFIG definido (${KUBECONFIG//:/ + })"
  kc_list="$KUBECONFIG"
fi
IFS=':' read -r -a kc_files <<<"$kc_list"
for kc in "${kc_files[@]}"; do
  [[ -n "$kc" ]] || continue
  if [[ ! -f "$kc" ]]; then
    ac_warn "arquivo de kubeconfig não existe: $kc"
    continue
  fi
  mode="$(stat -c '%a' "$kc" 2>/dev/null || echo '?')"
  if [[ "$mode" =~ ^[0-7]?[0-7][0-7]$ && "${mode: -2}" != "00" ]]; then
    ac_warn "permissão $mode em $kc — recomendado 600 (chmod 600)"
  else
    ac_ok "permissão $mode em $kc"
  fi
  case "$kc" in
    */install/auth/kubeconfig) ac_warn "este é o kubeconfig do instalador (system:admin). Use-o só para recuperação; veja docs/03-identidades-e-rbac.md" ;;
  esac
done

ac_title "3. Identidade e endpoint"
if capture ac_oc whoami; then
  user="$OUT"
  case "$user" in
    system:admin) ac_warn "identidade atual: system:admin — perfil de RECUPERAÇÃO; não use em exercícios comuns" ;;
    kube:admin)   ac_warn "identidade atual: kube:admin — acesso de emergência; prefira 'admin' ou 'developer'" ;;
    admin)        ac_ok "identidade atual: admin (perfil administrativo de treino)" ;;
    developer)    ac_ok "identidade atual: developer (perfil padrão dos exercícios)" ;;
    *)            ac_info "identidade atual: $user" ;;
  esac
else
  case "$(ac_classify_error "$ERR")" in
    unauthorized) ac_fail "sessão sem autenticação válida (token expirado ou logout). Faça oc login" ;;
    unreachable)  ac_fail "API inacessível: $(head -n1 <<<"$ERR")" ;;
    *)            ac_fail "oc whoami falhou: $(head -n1 <<<"$ERR")" ;;
  esac
  user=""
fi
if capture ac_oc whoami --show-server; then
  if [[ "$OUT" == "$ACADEMY_API_URL" ]]; then ac_ok "servidor: $OUT"; else ac_warn "servidor $OUT difere do esperado $ACADEMY_API_URL — confira o cluster-alvo"; fi
fi
if capture ac_oc whoami --show-context; then ac_info "contexto: $OUT"; fi
if capture ac_oc project -q; then ac_info "projeto atual: $OUT"; fi

ac_title "4. API do cluster"
if capture ac_oc get --raw /readyz; then
  if [[ "$OUT" == "ok" ]]; then ac_ok "/readyz respondeu ok"; else ac_warn "/readyz respondeu: $OUT"; fi
else
  ac_fail "/readyz falhou: $(head -n1 <<<"$ERR")"
fi

ac_title "5. Versão do cluster, nó e operadores"
if capture ac_oc get clusterversion version -o json; then
  if ac_have jq; then
    cv_ver="$(jq -r '.status.desired.version // "?"' <<<"$OUT")"
    cv_av="$(jq -r '[.status.conditions[]? | select(.type=="Available")][0].status // "?"' <<<"$OUT")"
    cv_pr="$(jq -r '[.status.conditions[]? | select(.type=="Progressing")][0].status // "?"' <<<"$OUT")"
    if [[ "$cv_av" == "True" && "$cv_pr" == "False" ]]; then
      ac_ok "ClusterVersion $cv_ver Available=$cv_av Progressing=$cv_pr"
    else
      ac_warn "ClusterVersion $cv_ver Available=$cv_av Progressing=$cv_pr — aguarde estabilizar antes de exercícios"
    fi
  else
    ac_ok "ClusterVersion legível (instale jq para detalhes)"
  fi
else
  if [[ "$(ac_classify_error "$ERR")" == forbidden ]]; then ac_skip "ClusterVersion: sem permissão (esperado para developer)"; else ac_warn "ClusterVersion: $(head -n1 <<<"$ERR")"; fi
fi

if capture ac_oc get nodes -o json; then
  if ac_have jq; then
    n_total="$(jq '.items | length' <<<"$OUT")"
    n_ready="$(jq '[.items[] | select(any(.status.conditions[]?; .type=="Ready" and .status=="True"))] | length' <<<"$OUT")"
    if [[ "$n_total" -ge 1 && "$n_total" == "$n_ready" ]]; then ac_ok "nós Ready: $n_ready/$n_total"; else ac_fail "nós Ready: $n_ready/$n_total"; fi
    [[ "$n_total" -eq 1 ]] && ac_info "topologia de nó único (SNO): sem redundância — nunca drenar/cordonar o nó"
  fi
else
  if [[ "$(ac_classify_error "$ERR")" == forbidden ]]; then ac_skip "nós: sem permissão (esperado para developer)"; else ac_warn "nós: $(head -n1 <<<"$ERR")"; fi
fi

if capture ac_oc get clusteroperators -o json; then
  if ac_have jq; then
    bad="$(jq -r '.items[] | {n:.metadata.name, c:(.status.conditions // [])}
      | select(any(.c[]; (.type=="Available" and .status!="True") or (.type=="Degraded" and .status=="True") or (.type=="Progressing" and .status=="True")))
      | .n' <<<"$OUT")"
    total="$(jq '.items | length' <<<"$OUT")"
    if [[ -z "$bad" ]]; then ac_ok "Cluster Operators estáveis: $total"; else ac_warn "operadores não estáveis: $(tr '\n' ' ' <<<"$bad")"; fi
  fi
else
  if [[ "$(ac_classify_error "$ERR")" == forbidden ]]; then ac_skip "Cluster Operators: sem permissão (esperado para developer)"; else ac_warn "Cluster Operators: $(head -n1 <<<"$ERR")"; fi
fi

ac_title "6. Capacidade (métricas)"
if capture ac_oc adm top nodes --no-headers; then
  while read -r name cpu cpup mem memp _; do
    [[ -n "${name:-}" ]] || continue
    mp="${memp%\%}"
    if [[ "$mp" =~ ^[0-9]+$ && "$mp" -ge 85 ]]; then
      ac_warn "$name: CPU $cpu ($cpup) | memória $mem ($memp) — memória alta, adie exercícios com workloads"
    else
      ac_ok "$name: CPU $cpu ($cpup) | memória $mem ($memp)"
    fi
  done <<<"$OUT"
else
  if [[ "$(ac_classify_error "$ERR")" == forbidden ]]; then ac_skip "métricas de nó: sem permissão"; else ac_warn "métricas indisponíveis: $(head -n1 <<<"$ERR")"; fi
fi

ac_title "7. Dependências de trilhas futuras"
if capture ac_oc get storageclass -o name; then
  n_sc="$(grep -c . <<<"$OUT" || true)"
  if [[ "$n_sc" -eq 0 ]]; then ac_info "StorageClasses: 0 — Trilha 09 (PV/PVC dinâmico) REQUER PREPARAÇÃO"; else ac_ok "StorageClasses: $n_sc"; fi
else
  if [[ "$(ac_classify_error "$ERR")" == forbidden ]]; then ac_skip "StorageClasses: sem permissão"; else ac_warn "StorageClasses: $(head -n1 <<<"$ERR")"; fi
fi
if capture ac_oc get configs.imageregistry.operator.openshift.io cluster -o 'jsonpath={.spec.managementState}'; then
  ac_info "registry interno: managementState=${OUT:-?} (builds/push internos dependem disso)"
else
  if [[ "$(ac_classify_error "$ERR")" == forbidden ]]; then ac_skip "registry interno: sem permissão"; else ac_info "registry interno: não consultado ($(head -n1 <<<"$ERR"))"; fi
fi

ac_title "8. Projetos de laboratório"
if capture ac_oc get projects -o name; then
  labs=()
  while read -r p; do
    p="${p#project.project.openshift.io/}"
    [[ -n "$p" ]] || continue
    if ac_ns_valid "$p"; then labs+=("$p"); fi
  done <<<"$OUT"
  if [[ ${#labs[@]} -eq 0 ]]; then ac_info "nenhum projeto ac*-* existente"; else ac_info "projetos de laboratório: ${labs[*]}"; fi
  [[ ${#labs[@]} -gt 5 ]] && ac_warn "${#labs[@]} projetos de laboratório ativos — considere limpar os que não estão em uso"
else
  ac_warn "não foi possível listar projetos: $(head -n1 <<<"$ERR")"
fi

if [[ -n "$KVM_SSH" ]]; then
  ac_title "9. Espaço físico do kvm-server (via SSH, leitura)"
  if ac_have ssh && capture ssh -o BatchMode=yes -o ConnectTimeout=5 "$KVM_SSH" df -P -B1G /var; then
    avail="$(awk 'NR==2 {print $4}' <<<"$OUT")"
    if [[ "$avail" =~ ^[0-9]+$ ]]; then
      if [[ "$avail" -ge "$MIN_FREE_GIB" ]]; then ac_ok "/var no host: ${avail} GiB livres (margem mínima ${MIN_FREE_GIB} GiB)"; else ac_fail "/var no host: ${avail} GiB livres — abaixo da margem de ${MIN_FREE_GIB} GiB"; fi
    else
      ac_warn "não foi possível interpretar df: $OUT"
    fi
  else
    ac_warn "SSH para $KVM_SSH indisponível (BatchMode): ${ERR:-ssh ausente}"
  fi
fi

printf '\nResumo: %d OK | %d AVISO | %d FALHA | %d PULADO\n' "$ACADEMY_N_OK" "$ACADEMY_N_WARN" "$ACADEMY_N_FAIL" "$ACADEMY_N_SKIP"
[[ "$ACADEMY_N_FAIL" -eq 0 ]]
