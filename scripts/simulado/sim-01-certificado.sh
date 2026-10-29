#!/usr/bin/env bash
# sim-01-certificado.sh — gera uma CA de treino e um certificado assinado por ela (tarefa 06 do Simulado 01).
#
# Executar em: student@ocp-admin. Não contata o cluster.
# Impacto:     LOCAL. Cria arquivos em DIR (padrão ~/sim-01/certs, permissão 600). As chaves privadas
#              NUNCA podem ficar dentro do repositório: o script recusa um DIR dentro dele.
# Uso:         sim-01-certificado.sh HOST "/C=../ST=../L=../O=../OU=../CN=HOST" [DIR]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() { sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }
case "${1:-}" in -h|--help) usage; exit 0 ;; esac
[[ $# -ge 2 ]] || { usage >&2; exit 2; }

HOST="$1"; SUBJ="$2"; DIR="${3:-$HOME/sim-01/certs}"
[[ "$SUBJ" == */CN="$HOST"* ]] || { echo "ERRO: o CN do assunto deve ser $HOST" >&2; exit 2; }
command -v openssl >/dev/null || { echo "ERRO: openssl não encontrado" >&2; exit 2; }

DIR="$(realpath -m "$DIR")"
case "$DIR/" in "$ROOT"/*) echo "ERRO: $DIR fica dentro do repositório; escolha outro diretório" >&2; exit 2 ;; esac
mkdir -p "$DIR"

umask 077
cd "$DIR"
openssl req -x509 -newkey rsa:2048 -nodes -days 30 -sha256 -keyout ca.key -out ca.crt \
  -subj "/C=BR/O=Academia/CN=Academia Simulado CA" 2>/dev/null
openssl req -newkey rsa:2048 -nodes -sha256 -keyout "$HOST.key" -out "$HOST.csr" -subj "$SUBJ" 2>/dev/null
openssl x509 -req -in "$HOST.csr" -CA ca.crt -CAkey ca.key -CAcreateserial -days 30 -sha256 \
  -extfile <(printf 'subjectAltName=DNS:%s\nextendedKeyUsage=serverAuth\n' "$HOST") -out "$HOST.crt" 2>/dev/null
rm -f "$HOST.csr" ca.srl

echo "Arquivos em $DIR:"
echo "  certificado: $HOST.crt   chave: $HOST.key   CA: ca.crt"
openssl x509 -in "$HOST.crt" -noout -subject -issuer -enddate
