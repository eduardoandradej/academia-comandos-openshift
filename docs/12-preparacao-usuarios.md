# Preparação de usuários de treino no HTPasswd (DO280)

> **VERMELHO — MUTAÇÃO DE CLUSTER, MANUAL.** Este roteiro acrescenta usuários de treino do DO280 (por exemplo
> `leader`, `qa-engineer`) ao provedor `homelab-users`. Ele altera o Secret `homelab-users-htpasswd` em
> `openshift-config` e faz o OAuth reiniciar. A Academia **não** automatiza isto. A Trilha 15 inteira funciona
> **sem** este roteiro (usa service accounts e impersonação); use-o só quando um exercício do curso pedir usuários reais.

## Regras

- Faça como `admin`, com o perfil de recuperação (`ac-recovery`) **testado antes** — é ele que salva você se o login quebrar.
- **Nunca** remova o provedor `homelab-users`, o usuário `admin` nem o `kubeadmin`.
- Senhas **sempre no prompt** (`htpasswd -B` sem `-b`). As senhas de treino do DO280 são públicas e valem só no HomeLab.
- Cópias de segurança ficam em `~/backups` (permissão 600), **fora** do repositório. Nunca comite o arquivo HTPasswd.
- REQUER PREPARAÇÃO: comando `htpasswd` (pacote `httpd-tools`) na `ocp-admin`.

## 1. Conferir e guardar o estado atual

```bash
source scripts/perfis.sh && ac-recovery && oc whoami && ac-admin && oc whoami     # os dois perfis respondem?
oc get oauth cluster -o jsonpath='{.spec.identityProviders[*].name}{"\n"}'        # homelab-users
oc get secret homelab-users-htpasswd -n openshift-config -o jsonpath='{.data}' | jq 'keys'   # ["htpasswd"]
umask 077; mkdir -p ~/backups; D=$(mktemp -d)
oc extract secret/homelab-users-htpasswd -n openshift-config --keys=htpasswd --to="$D" --confirm
cp "$D/htpasswd" ~/backups/htpasswd.$(date +%Y%m%d-%H%M).orig
cut -d: -f1 "$D/htpasswd"                      # só os nomes de usuário
```

## 2. Acrescentar usuários

```bash
htpasswd -B "$D/htpasswd" leader               # pede a senha (não use -b)
htpasswd -B "$D/htpasswd" qa-engineer
cut -d: -f1 "$D/htpasswd"                      # confira: os antigos continuam + os novos
oc set data secret/homelab-users-htpasswd -n openshift-config --from-file=htpasswd="$D/htpasswd"
rm -rf "$D"; unset D
```

## 3. Acompanhar e testar

```bash
oc get pods -n openshift-authentication -w     # novos pods do OAuth (Ctrl+C quando estiverem Running)
oc get co authentication                       # Available=True, Progressing=False
KUBECONFIG="$HOME/.kube/ac-leader.kubeconfig" oc login -u leader https://api.ocp.example.lab:6443   # senha no prompt
KUBECONFIG="$HOME/.kube/ac-leader.kubeconfig" oc whoami
oc whoami                                      # o perfil admin continua funcionando
```

## Desfazer

Remover usuários de treino:

```bash
D=$(mktemp -d); oc extract secret/homelab-users-htpasswd -n openshift-config --keys=htpasswd --to="$D" --confirm
htpasswd -D "$D/htpasswd" leader; htpasswd -D "$D/htpasswd" qa-engineer
oc set data secret/homelab-users-htpasswd -n openshift-config --from-file=htpasswd="$D/htpasswd"; rm -rf "$D"
oc delete user leader qa-engineer --ignore-not-found
oc delete identity homelab-users:leader homelab-users:qa-engineer --ignore-not-found
rm -f ~/.kube/ac-leader.kubeconfig
```

Se o login de todos quebrar: `ac-recovery` e restaure a cópia —
`oc set data secret/homelab-users-htpasswd -n openshift-config --from-file=htpasswd=$HOME/backups/htpasswd.<data>.orig`.
