# shellcheck shell=bash
# common.sh — funções compartilhadas pelos scripts da Academia de Comandos: OpenShift.
# Este arquivo é carregado com "source"; não deve ser executado diretamente.
# Nenhuma função aqui altera o cluster.
# shellcheck disable=SC2034  # variáveis usadas pelos scripts que carregam este arquivo

# Rótulo obrigatório de todo recurso criado pelos exercícios.
ACADEMY_LABEL_KEY="academy.openshift.dev/managed-by"
ACADEMY_LABEL_VALUE="academia"
ACADEMY_LABEL="${ACADEMY_LABEL_KEY}=${ACADEMY_LABEL_VALUE}"

# Namespaces de laboratório: "ac-<tema>" ou "acNN-<tema>" (NN = número da trilha).
ACADEMY_NS_REGEX='^ac([0-9]{2})?-[a-z0-9]([-a-z0-9]*[a-z0-9])?$'

# Endpoint esperado da API do HomeLab (pode ser sobrescrito por variável de ambiente).
ACADEMY_API_URL="${ACADEMY_API_URL:-https://api.ocp.example.lab:6443}"

# Tempo máximo de cada chamada à API.
ACADEMY_TIMEOUT="${ACADEMY_TIMEOUT:-15s}"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_OK=$'\e[32m'; C_WARN=$'\e[33m'; C_FAIL=$'\e[31m'; C_INFO=$'\e[36m'; C_DIM=$'\e[2m'; C_RST=$'\e[0m'
else
  C_OK=''; C_WARN=''; C_FAIL=''; C_INFO=''; C_DIM=''; C_RST=''
fi

ACADEMY_N_OK=0
ACADEMY_N_WARN=0
ACADEMY_N_FAIL=0
ACADEMY_N_SKIP=0

ac_ok()   { ACADEMY_N_OK=$((ACADEMY_N_OK + 1));     printf '%s[ OK    ]%s %s\n' "$C_OK" "$C_RST" "$*"; }
ac_warn() { ACADEMY_N_WARN=$((ACADEMY_N_WARN + 1)); printf '%s[ AVISO ]%s %s\n' "$C_WARN" "$C_RST" "$*"; }
ac_fail() { ACADEMY_N_FAIL=$((ACADEMY_N_FAIL + 1)); printf '%s[ FALHA ]%s %s\n' "$C_FAIL" "$C_RST" "$*"; }
ac_skip() { ACADEMY_N_SKIP=$((ACADEMY_N_SKIP + 1)); printf '%s[ PULADO]%s %s\n' "$C_DIM" "$C_RST" "$*"; }
ac_info() { printf '%s[ INFO  ]%s %s\n' "$C_INFO" "$C_RST" "$*"; }
ac_title() { printf '\n%s== %s ==%s\n' "$C_INFO" "$*" "$C_RST"; }
ac_die()  { printf '%sERRO:%s %s\n' "$C_FAIL" "$C_RST" "$*" >&2; exit 2; }

ac_no_color() { C_OK=''; C_WARN=''; C_FAIL=''; C_INFO=''; C_DIM=''; C_RST=''; }

ac_have() { command -v "$1" >/dev/null 2>&1; }

# Valida o nome de um namespace de laboratório. Retorna 0 se aceito.
ac_ns_valid() {
  local ns="${1:-}"
  [[ "$ns" =~ $ACADEMY_NS_REGEX ]] || return 1
  [[ ${#ns} -le 63 ]] || return 1
  return 0
}

# Executa "oc" com timeout de requisição. Saída padrão e de erro vão para o chamador.
ac_oc() {
  oc --request-timeout="$ACADEMY_TIMEOUT" "$@"
}

# Classifica uma mensagem de erro do oc. Imprime: forbidden | unauthorized | notfound | unreachable | other
ac_classify_error() {
  local msg="${1:-}"
  case "$msg" in
    *[Ff]orbidden*) echo forbidden ;;
    *Unauthorized*|*"must be logged in"*) echo unauthorized ;;
    *NotFound*|*"not found"*|*"doesn't have a resource type"*) echo notfound ;;
    *"no such host"*|*"connection refused"*|*"i/o timeout"*|*"deadline exceeded"*|*"Unable to connect"*|*"no route to host"*) echo unreachable ;;
    *) echo other ;;
  esac
}
