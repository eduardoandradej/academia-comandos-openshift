#!/usr/bin/env bash
# check-repo.sh — validação estática do repositório (usada na CI). Não contata nenhum cluster.
#
# Verifica: seções obrigatórias dos exercícios, ID do arquivo × título, existência do gabarito,
# gabarito fora da pasta de trilhas, links internos relativos, mínimo de exercícios por trilha
# disponível e assinaturas de segredos.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

ERRORS=0
err() { ERRORS=$((ERRORS + 1)); printf 'ERRO: %s\n' "$*"; }

REQUIRED=(
  "## Identificação"
  "## Objetivo e indicador de sucesso"
  "## Nível"
  "## Duração e repetições"
  "## Contexto"
  "## Pré-flight"
  "## Conceito"
  "## Comandos guiados"
  "## Repetições"
  "## Desafio sem pista"
  "## Diagnóstico controlado"
  "## Validação"
  "## Limpeza segura"
  "## Gabarito"
  "## Ficha de revisão"
)

echo "# exercícios"
n_ex=0
for f in trilhas/*/exercicios/*.md; do
  [[ -f "$f" ]] || continue
  n_ex=$((n_ex + 1))
  id="$(basename "$f" .md)"
  trilha="$(basename "$(dirname "$(dirname "$f")")")"
  head -n1 "$f" | grep -q "^# $id — " || err "$f: título deve começar com '# $id — '"
  mapfile -t found < <(grep -E '^## ' "$f")
  if [[ "${found[*]}" != "${REQUIRED[*]}" ]]; then
    err "$f: seções fora do padrão. Esperado: ${REQUIRED[*]} | Encontrado: ${found[*]}"
  fi
  grep -q '^\*\*Nível:\*\* ' "$f" || err "$f: linha '**Nível:** ...' ausente"
  [[ -f "solucoes/$trilha/$id.md" ]] || err "$f: gabarito solucoes/$trilha/$id.md não existe"
  grep -qE '^# Gabarito' "$f" && err "$f: contém gabarito no corpo do exercício"
done
for d in trilhas/*/; do
  [[ -d "$d/exercicios" ]] || continue
  c="$(find "$d/exercicios" -name '*.md' | wc -l)"
  [[ "$c" -ge 15 ]] || err "$d: trilha publicada com menos de 15 exercícios ($c)"
done
echo "  $n_ex exercícios verificados"

echo "# cenários"
for f in cenarios/troubleshooting/TS-*.md; do
  [[ -f "$f" ]] || continue
  id="$(basename "$f" .md)"
  head -n1 "$f" | grep -q "^# $id — " || err "$f: título deve começar com '# $id — '"
  for s in "## Sintoma" "## Como reproduzir com segurança" "## Hipóteses a testar" "## Investigação orientada" "## Limpeza" "## Gabarito"; do
    grep -qxF "$s" "$f" || err "$f: seção '$s' ausente"
  done
  [[ -f "solucoes/cenarios/$id.md" ]] || err "$f: gabarito solucoes/cenarios/$id.md não existe"
done

echo "# links internos"
while IFS= read -r f; do
  case "$f" in templates/*) continue ;; esac
  dir="$(dirname "$f")"
  while IFS= read -r target; do
    target="${target%%#*}"
    [[ -z "$target" || "$target" =~ ^(https?|mailto): ]] && continue
    [[ -e "$dir/$target" ]] || err "$f: link quebrado -> $target"
  done < <(grep -oE '\]\([^) ]+\)' "$f" | sed -E 's/^\]\(//; s/\)$//')
done < <(git ls-files --cached --others --exclude-standard '*.md')

echo "# segredos"
patterns='-----BEGIN [A-Z ]*PRIVATE KEY-----|sha256~[A-Za-z0-9_-]{20,}|"auths"[[:space:]]*:[[:space:]]*\{|client-key-data:[[:space:]]*[A-Za-z0-9+/=]{20,}|token:[[:space:]]*[A-Za-z0-9._-]{30,}'
if git ls-files --cached --others --exclude-standard | grep -v '^scripts/dev/check-repo.sh$' \
    | xargs -r grep -nIE -- "$patterns" 2>/dev/null; then
  err "possível segredo encontrado (veja as linhas acima)"
fi
if git ls-files --cached --others --exclude-standard | grep -Ei '(kubeconfig$|pull-secret|kubeadmin-password|\.htpasswd$|id_(rsa|ed25519)$|\.key$)'; then
  err "arquivo com nome sensível no repositório"
fi

echo "# scripts"
for s in scripts/*.sh scripts/academy scripts/dev/*.sh scripts/simulado/*.sh tests/run-tests.sh tests/mocks/oc; do
  [[ "$s" == scripts/perfis.sh ]] && continue   # carregado com source: sem set -e nem bit de execução
  grep -q '^set -euo pipefail' "$s" || err "$s: falta 'set -euo pipefail'"
  [[ -x "$s" ]] || err "$s: sem permissão de execução"
done

if [[ "$ERRORS" -gt 0 ]]; then
  printf '\n%d erro(s)\n' "$ERRORS"
  exit 1
fi
printf '\nOK: repositório consistente\n'
