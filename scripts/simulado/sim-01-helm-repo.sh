#!/usr/bin/env bash
# sim-01-helm-repo.sh — monta um repositório Helm local com o chart ac14-loja (tarefa 08 do Simulado 01).
#
# Executar em: student@ocp-admin. REQUER PREPARAÇÃO: cliente helm (docs/11) e python3.
# Impacto:     LOCAL. Empacota o chart em DIR (padrão ~/sim-01/helm-repo) e, com --servir, publica-o
#              em http://127.0.0.1:8879 (só na própria máquina) até você apertar Ctrl+C. Não contata o cluster.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DIR="$HOME/sim-01/helm-repo"
SERVIR=0

usage() { echo "Uso: sim-01-helm-repo.sh [--servir] [--dir DIR]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --servir) SERVIR=1 ;;
    --dir) DIR="${2:?}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

command -v helm >/dev/null || { echo "ERRO: helm não encontrado (REQUER PREPARAÇÃO: docs/11)" >&2; exit 2; }
mkdir -p "$DIR"
helm package "$ROOT/manifests/helm/ac14-loja" -d "$DIR" >/dev/null
helm repo index "$DIR" --url http://127.0.0.1:8879
echo "repositório em $DIR:"; ls "$DIR"

if [[ "$SERVIR" -eq 1 ]]; then
  command -v python3 >/dev/null || { echo "ERRO: python3 não encontrado" >&2; exit 2; }
  echo "servindo em http://127.0.0.1:8879 — deixe este terminal aberto; Ctrl+C encerra"
  exec python3 -m http.server 8879 --bind 127.0.0.1 --directory "$DIR"
fi
