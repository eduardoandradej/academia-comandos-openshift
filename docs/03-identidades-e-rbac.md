# Identidades e RBAC

## Identidades de treino

Os nomes seguem os materiais DO180/DO280 para manter os exemplos compatíveis. As senhas são **públicas e inseguras**
e valem **apenas neste HomeLab isolado**.

| Contexto | Identidade | Senha de treino | Regra |
|---|---|---|---|
| OpenShift, administração | `admin` | `redhatocp` | `cluster-admin` via HTPasswd `homelab-users` |
| OpenShift, padrão | `developer` | `developer` | sem privilégios de cluster; perfil padrão dos exercícios |
| DO280, IdP | `new_admin` / `new_developer` | `redhat` / `developer` | criar **somente** no exercício de identidade do DO280 |
| DO280, RBAC | `leader`, `qa-engineer`, grupos `dev-group`, `qa-group` | conforme o exercício | criar no momento do exercício |
| DO280 | `manager` | conforme o exercício | criado e removido no exercício |
| Estação Red Hat | `student` / `root` | `student` / `redhat` | referência didática; **não** alterar senhas da `ocp-admin`, do host ou do RHCOS |

Os nomes `localusers` (Secret) e `myusers` (IdP) ficam reservados ao exercício do DO280; o provedor permanente do
HomeLab é `homelab-users`, com Secret `homelab-users-htpasswd` em `openshift-config`.

## Perfis do terminal

| Perfil | Kubeconfig | Autenticação | Uso |
|---|---|---|---|
| `developer` | `~/.kube/ac-developer.kubeconfig` | token OAuth (`oc login`) | **padrão** |
| `admin` | `~/.kube/ac-admin.kubeconfig` | token OAuth | exercícios administrativos |
| `system:admin` | `~/openshift-lab/ocp422-sno/install/auth/kubeconfig` | certificado de cliente | **recuperação**; nunca padrão |
| `kube:admin` | — | senha temporária do instalador | emergência; preservar até `admin` estar validado |

Os perfis são criados no [ORI-004](../trilhas/00-orientacao/exercicios/ORI-004.md). Para alternar:

```bash
source scripts/perfis.sh
ac-dev        # developer
ac-admin      # admin
ac-recovery   # system:admin, com aviso
ac-perfil     # mostra KUBECONFIG e oc whoami
```

### Por que separar kubeconfigs

O `~/.bashrc` da `ocp-admin` exporta o kubeconfig do instalador. Sem separação, (1) todo terminal novo nasce como
`system:admin`, mascarando erros de permissão que os exercícios querem ensinar, e (2) um `oc login` grava o token
do novo usuário **dentro** do arquivo sigiloso. Opcionalmente, você pode trocar a linha do `~/.bashrc` por
`export KUBECONFIG="$HOME/.kube/ac-developer.kubeconfig"` — decisão sua; a Academia não edita seus arquivos de shell.

## Verificar antes de propor mudanças

Não presuma que o HTPasswd está pronto só porque `users.htpasswd` existe:

```bash
oc get oauth cluster -o jsonpath='{.spec.identityProviders[*].name}{"\n"}'   # homelab-users?
oc get users; oc get identities
oc auth can-i '*' '*' --all-namespaces --as=admin                           # yes
oc auth can-i get nodes --as=developer                                       # no
```

Configurar ou alterar o IdP é **MUTAÇÃO DE CLUSTER (VERMELHO)**: siga a apostila do HomeLab manualmente, preservando
provedores existentes e mantendo o acesso de recuperação.

## Perfis nos exercícios

Cada exercício declara o perfil em **Contexto**. Os desafios se organizam por `developer` (sem privilégios), `admin`
(administração) e `system:admin` (recuperação, raríssimo e sempre justificado).
