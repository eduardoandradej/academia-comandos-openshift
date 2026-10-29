#!/usr/bin/env bash
# sim-01-prepara.sh — cria os projetos e as aplicações que já existem no início do Simulado 01.
#
# Executar em: student@ocp-admin, perfil developer (source scripts/perfis.sh && ac-dev)
# Impacto:     padrão = LEITURA (mostra o plano). Com --execute = MUTAÇÃO LOCAL REVERSÍVEL:
#              cria 8 projetos ac-sim-* e aplica manifests/simulado/sim-01-preparo.yaml.
# Desfazer:    scripts/simulado/sim-01-limpa.sh --execute
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/scripts/lib/common.sh"

PROJETOS="ac-sim-vitrine ac-sim-painel ac-sim-cofre ac-sim-raiz ac-sim-memoria ac-sim-dados ac-sim-cliente ac-sim-intruso"
MANIFESTO="$ROOT/manifests/simulado/sim-01-preparo.yaml"
EXECUTE=0

usage() {
  cat <<USO
Uso: sim-01-prepara.sh [--execute]

Sem opções, só mostra o que seria criado. Com --execute, cria os projetos
($PROJETOS)
e aplica $MANIFESTO.
USO
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute) EXECUTE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

ac_have oc || ac_die "comando oc não encontrado"
eu="$(oc whoami 2>/dev/null)" || ac_die "sem sessão no cluster: faça login (perfil ac-dev)"
case "$eu" in
  system:admin|kube:admin) ac_die "identidade $eu recusada: use o perfil developer (ac-dev)" ;;
esac
ac_info "identidade: $eu"
[[ "$eu" == developer ]] || ac_warn "o simulado foi pensado para o usuário developer"

ac_title "Plano"
for p in $PROJETOS; do ac_info "projeto $p"; done
ac_info "manifesto $(basename "$MANIFESTO"): $(grep -c '^kind:' "$MANIFESTO") objetos"

if [[ "$EXECUTE" -eq 0 ]]; then
  ac_info "simulação: nada foi alterado (use --execute)"
  exit 0
fi

ac_title "Criando"
for p in $PROJETOS; do
  if oc get project "$p" >/dev/null 2>&1; then
    ac_skip "$p já existe"
  else
    oc new-project "$p" --skip-config-write --display-name="Academia - Simulado 01" >/dev/null && ac_ok "$p criado"
  fi
done
oc apply -f "$MANIFESTO"

ac_title "Endereços"
oc get routes -l academy.openshift.dev/simulado=sim-01 -A -o custom-columns=PROJETO:.metadata.namespace,ROUTE:.metadata.name,HOST:.spec.host 2>/dev/null \
  || for p in ac-sim-vitrine ac-sim-painel ac-sim-cofre; do oc get route -n "$p" -o custom-columns=ROUTE:.metadata.name,HOST:.spec.host --no-headers; done
ac_info "pronto: marque o horário e comece pelo enunciado (simulados/sim-01/README.md)"
