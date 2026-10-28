#!/usr/bin/env bash
# run-tests.sh — testes offline dos scripts, com um "oc" simulado (tests/mocks/oc).
# Não contata nenhum cluster. Uso: tests/run-tests.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$ROOT/tests/mocks:$PATH"
export NO_COLOR=1
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export MOCK_LOG="$TMP/calls.log"

PASS=0
FAIL=0
pass() { PASS=$((PASS + 1)); printf 'ok   - %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf 'FAIL - %s\n' "$1"; [[ -n "${2:-}" ]] && printf '       %s\n' "$2"; }

# run NOME ESPERADO_RC comando... ; guarda saída em $TMP/out
run() {
  local name="$1" want="$2" rc=0
  shift 2
  "$@" >"$TMP/out" 2>&1 </dev/null || rc=$?
  if [[ "$rc" -eq "$want" ]]; then pass "$name (rc=$rc)"; else fail "$name" "rc=$rc, esperado $want: $(tail -n3 "$TMP/out" | tr '\n' ' ')"; fi
}
has() { if grep -qF -- "$2" "$TMP/out"; then pass "$1"; else fail "$1" "texto ausente: $2"; fi; }
hasnt() { if grep -qF -- "$2" "$TMP/out"; then fail "$1" "texto inesperado: $2"; else pass "$1"; fi; }
no_mutation() {
  if grep -Eq '^(create|apply|replace|patch|edit|delete|label|annotate|scale|set|rollout|expose|new-project|new-app|run|adm (drain|cordon|uncordon|upgrade|policy|groups)|login|logout)( |$)' "$MOCK_LOG" 2>/dev/null; then
    fail "$1" "chamada mutável registrada: $(grep -E '^(create|apply|delete|patch|label|adm)' "$MOCK_LOG" | head -n1)"
  else
    pass "$1"
  fi
}

echo "# detector de mutação (controle positivo)"
printf 'delete configmap x -n ac00-orientacao\n' >"$MOCK_LOG"
if grep -Eq '^(create|apply|delete)( |$)' "$MOCK_LOG"; then pass "detector reconhece uma chamada delete"; else fail "detector reconhece uma chamada delete"; fi

echo "# preflight.sh"
: >"$MOCK_LOG"
MOCK_PROFILE="developer" run "preflight como developer termina sem FALHA" 0 "$ROOT/scripts/preflight.sh"
has "developer: ClusterVersion marcado como PULADO" "ClusterVersion: sem permissão"
has "developer: identidade reconhecida" "identidade atual: developer"
has "lista somente projetos de laboratório" "projetos de laboratório: ac00-orientacao"
hasnt "não lista projetos fora do padrão" "meu-app"
no_mutation "preflight (developer) não faz chamadas mutáveis"

: >"$MOCK_LOG"
MOCK_PROFILE="admin" run "preflight como admin termina sem FALHA" 0 "$ROOT/scripts/preflight.sh"
has "admin: versão do cluster" "ClusterVersion 4.22.0 Available=True Progressing=False"
has "admin: nó Ready" "nós Ready: 1/1"
has "admin: operador em progresso vira AVISO" "operadores não estáveis: monitoring"
has "admin: StorageClass ausente sinalizada" "REQUER PREPARAÇÃO"
no_mutation "preflight (admin) não faz chamadas mutáveis"

: >"$MOCK_LOG"
MOCK_PROFILE="down" run "preflight com API inacessível retorna 1" 1 "$ROOT/scripts/preflight.sh"
has "API inacessível é diagnosticada" "API inacessível"
run "preflight rejeita opção desconhecida" 2 "$ROOT/scripts/preflight.sh" --xyz
run "preflight --help" 0 "$ROOT/scripts/preflight.sh" --help

echo "# safe-cleanup.sh"
: >"$MOCK_LOG"
run "recusa namespace openshift-console" 2 "$ROOT/scripts/safe-cleanup.sh" -n openshift-console
run "recusa namespace default" 2 "$ROOT/scripts/safe-cleanup.sh" -n default
run "recusa namespace kube-system" 2 "$ROOT/scripts/safe-cleanup.sh" -n kube-system
run "recusa namespace sem prefixo ac" 2 "$ROOT/scripts/safe-cleanup.sh" -n meu-app
run "recusa -A" 2 "$ROOT/scripts/safe-cleanup.sh" -n ac00-orientacao -A
run "recusa --all" 2 "$ROOT/scripts/safe-cleanup.sh" -n ac00-orientacao --all
run "recusa seletor fora de academy.openshift.dev/" 2 "$ROOT/scripts/safe-cleanup.sh" -n ac00-orientacao -l app=demo
run "recusa seletor com operador de conjunto" 2 "$ROOT/scripts/safe-cleanup.sh" -n ac00-orientacao -l 'academy.openshift.dev/managed-by!=x'
run "recusa --delete-project sem --execute" 2 "$ROOT/scripts/safe-cleanup.sh" -n ac00-orientacao --delete-project
no_mutation "recusas não chegam a chamar o oc para mutar"

: >"$MOCK_LOG"
run "simulação padrão (sem --execute)" 0 "$ROOT/scripts/safe-cleanup.sh" -n ac00-orientacao
has "simulação lista alvos" "configmap/ac00-cfg"
has "simulação avisa que nada foi apagado" "SIMULAÇÃO: nada foi apagado"
no_mutation "simulação não faz chamadas mutáveis"

: >"$MOCK_LOG"
run "--execute sem terminal e sem --confirm é recusado" 2 "$ROOT/scripts/safe-cleanup.sh" -n ac00-orientacao --execute
run "--confirm divergente é recusado" 2 "$ROOT/scripts/safe-cleanup.sh" -n ac00-orientacao --execute --confirm ac00-outro
no_mutation "confirmações inválidas não apagam nada"

: >"$MOCK_LOG"
export MOCK_STATE="$TMP/deleted"
run "--execute com confirmação apaga por rótulo" 0 "$ROOT/scripts/safe-cleanup.sh" -n ac00-orientacao --execute --confirm ac00-orientacao --delete-project
if grep -q -- '-l academy.openshift.dev/managed-by=academia' "$MOCK_LOG" && grep -q '^delete .* -n ac00-orientacao -l ' "$MOCK_LOG"; then pass "delete usa namespace e rótulo"; else fail "delete usa namespace e rótulo"; fi
if grep -Eq -- '(^| )(--all|-A|--all-namespaces)( |$)' "$MOCK_LOG"; then fail "nenhuma chamada usa --all/-A"; else pass "nenhuma chamada usa --all/-A"; fi
has "projeto criado pelo próprio usuário pode ser apagado" "Apagando o projeto ac00-orientacao"
unset MOCK_STATE

run "namespace inexistente: nada a limpar" 0 "$ROOT/scripts/safe-cleanup.sh" -n ac99-inexistente
has "mensagem de nada a limpar" "nada a limpar"

echo "# status.sh"
: >"$MOCK_LOG"
run "status.sh recusa namespace fora do padrão" 2 "$ROOT/scripts/status.sh" -n openshift-monitoring
no_mutation "status.sh não faz chamadas mutáveis"

echo "# academy"
run "academy help" 0 "$ROOT/scripts/academy" help
has "help menciona que não é o lab oficial" "não é o \"lab\" oficial"
run "academy version" 0 "$ROOT/scripts/academy" version
run "academy list" 0 "$ROOT/scripts/academy" list
has "list mostra ORI-001" "ORI-001"
has "list mostra ORI-015" "ORI-015"
has "list mostra CON-015" "CON-015"
has "list mostra cenário TS-009" "TS-009"
has "list mostra PRJ-015" "PRJ-015"
has "list mostra cenário TS-012" "TS-012"
has "list mostra POD-015" "POD-015"
has "list mostra cenário TS-015" "TS-015"
has "list mostra DEP-015" "DEP-015"
has "list mostra cenário TS-018" "TS-018"
has "list mostra SVC-015" "SVC-015"
has "list mostra cenário TS-021" "TS-021"
has "list mostra RTE-015" "RTE-015"
has "list mostra cenário TS-024" "TS-024"
has "list mostra CFG-015" "CFG-015"
has "list mostra cenário TS-027" "TS-027"
has "list mostra STO-015" "STO-015"
has "list mostra cenário TS-030" "TS-030"
has "list mostra IMG-015" "IMG-015"
has "list mostra cenário TS-033" "TS-033"
run "academy list --trilha 00" 0 "$ROOT/scripts/academy" list --trilha 00
has "filtro por trilha mostra a trilha pedida" "ORI-001"
run "academy list --trilha 99 (vazia)" 0 "$ROOT/scripts/academy" list --trilha 99
hasnt "filtro por trilha exclui outras trilhas" "ORI-001"
run "academy list --trilha inválida" 2 "$ROOT/scripts/academy" list --trilha 1
run "academy list --trilha 01" 0 "$ROOT/scripts/academy" list --trilha 01
has "trilha 01 lista CLI-015" "CLI-015"
hasnt "trilha 01 não lista ORI" "ORI-001"
run "academy review CLI-004" 0 "$ROOT/scripts/academy" review CLI-004
has "review CLI-004 mostra a ficha" "Ficha de revisão"
run "academy show ORI-001" 0 "$ROOT/scripts/academy" show ORI-001
has "show imprime o enunciado" "## Desafio sem pista"
hasnt "show não imprime o gabarito" "# Gabarito ORI-001"
run "academy show ID inválido" 2 "$ROOT/scripts/academy" show 'ORI-1;rm'
run "academy show ID inexistente" 2 "$ROOT/scripts/academy" show ZZZ-999
run "academy review ORI-004" 0 "$ROOT/scripts/academy" review ORI-004
has "review mostra só a ficha de revisão" "## Ficha de revisão"
hasnt "review não mostra comandos guiados" "## Comandos guiados"
run "academy where ORI-008" 0 "$ROOT/scripts/academy" where ORI-008
has "where aponta o gabarito" "solucoes/00-orientacao/ORI-008.md"
run "academy where CON-008" 0 "$ROOT/scripts/academy" where CON-008
has "where aponta gabarito da trilha 02" "solucoes/02-consultas/CON-008.md"
run "academy show TS-009 (cenário)" 0 "$ROOT/scripts/academy" show TS-009
has "show de cenário imprime o sintoma" "## Sintoma"
run "academy where PRJ-009" 0 "$ROOT/scripts/academy" where PRJ-009
has "where aponta gabarito da trilha 03" "solucoes/03-projetos/PRJ-009.md"
run "academy review POD-009" 0 "$ROOT/scripts/academy" review POD-009
has "review POD-009 mostra a ficha" "Ficha de revisão"
run "academy where DEP-004" 0 "$ROOT/scripts/academy" where DEP-004
has "where aponta gabarito da trilha 05" "solucoes/05-deployments/DEP-004.md"
run "academy review SVC-006" 0 "$ROOT/scripts/academy" review SVC-006
has "review SVC-006 mostra a ficha" "Ficha de revisão"
run "academy where RTE-007" 0 "$ROOT/scripts/academy" where RTE-007
has "where aponta gabarito da trilha 07" "solucoes/07-rotas/RTE-007.md"
run "academy where CFG-010" 0 "$ROOT/scripts/academy" where CFG-010
has "where aponta gabarito da trilha 08" "solucoes/08-config/CFG-010.md"
run "academy review CFG-005" 0 "$ROOT/scripts/academy" review CFG-005
has "review CFG-005 mostra a ficha" "Ficha de revisão"
run "academy where STO-008" 0 "$ROOT/scripts/academy" where STO-008
has "where aponta gabarito da trilha 09" "solucoes/09-storage/STO-008.md"
run "academy where IMG-008" 0 "$ROOT/scripts/academy" where IMG-008
has "where aponta gabarito da trilha 10" "solucoes/10-imagens/IMG-008.md"
run "academy start não implementado" 3 "$ROOT/scripts/academy" start ORI-001
run "academy comando desconhecido" 2 "$ROOT/scripts/academy" xyz
: >"$MOCK_LOG"
MOCK_PROFILE="developer" run "academy doctor delega ao preflight" 0 "$ROOT/scripts/academy" doctor
no_mutation "academy doctor não faz chamadas mutáveis"

printf '\n%d passaram, %d falharam\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]]
