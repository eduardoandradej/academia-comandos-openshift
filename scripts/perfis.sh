# shellcheck shell=bash
# perfis.sh — funções para alternar o perfil do terminal (carregar com: source scripts/perfis.sh).
#
# Impacto: só altera a variável KUBECONFIG do shell atual. Não lê o conteúdo dos arquivos,
# não faz login e não contata o cluster (exceto ac-perfil, que roda "oc whoami").
# Os arquivos de perfil são criados no exercício ORI-004 e ficam FORA do repositório.

AC_KC_DEV="${AC_KC_DEV:-$HOME/.kube/ac-developer.kubeconfig}"
AC_KC_ADMIN="${AC_KC_ADMIN:-$HOME/.kube/ac-admin.kubeconfig}"
AC_KC_RECOVERY="${AC_KC_RECOVERY:-$HOME/openshift-lab/ocp422-sno/install/auth/kubeconfig}"

_ac_use() {
  if [[ ! -f "$1" ]]; then
    printf 'perfil indisponível: %s não existe (veja trilhas/00-orientacao/exercicios/ORI-004.md)\n' "$1" >&2
    return 1
  fi
  export KUBECONFIG="$1"
  printf 'KUBECONFIG=%s\n' "$KUBECONFIG"
}

# Perfil padrão dos exercícios.
ac-dev() { _ac_use "$AC_KC_DEV"; }

# Perfil administrativo de treino.
ac-admin() { _ac_use "$AC_KC_ADMIN"; }

# Perfil de RECUPERAÇÃO (system:admin). Use só quando um exercício pedir explicitamente.
ac-recovery() {
  _ac_use "$AC_KC_RECOVERY" || return 1
  printf 'ATENÇÃO: perfil de recuperação (system:admin). Volte com ac-dev ao terminar.\n' >&2
}

# Mostra o perfil atual sem revelar credenciais.
ac-perfil() {
  printf 'KUBECONFIG=%s\n' "${KUBECONFIG:-<não definido: ~/.kube/config>}"
  printf 'identidade=%s\n' "$(oc whoami 2>/dev/null || echo '<sem sessão válida>')"
}
