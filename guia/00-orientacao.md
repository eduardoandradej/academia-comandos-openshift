# Guia direto 00 — Orientação e segurança

> Comandos para rodar na `ocp-admin`, como `student`. Cada bloco traz os comandos, e a tabela logo abaixo explica cada um.
> **Leitura** = não altera nada · **Altera** = muda algo só no projeto de treino ou nos seus arquivos.
> Exercícios completos desta trilha: [trilhas/00-orientacao](../trilhas/00-orientacao/README.md).

## 1. Onde estou (sem tocar no cluster) — Leitura

```bash
hostnamectl --static
whoami
ip -br addr
command -v oc kubectl jq
oc version --client
```

| Comando | O que faz |
|---|---|
| `hostnamectl --static` | nome da máquina (esperado: `ocp-admin`) |
| `whoami` | usuário **Linux** (não é o usuário do OpenShift) |
| `ip -br addr` | IPs da máquina, uma linha por interface |
| `command -v oc kubectl jq` | mostra onde cada ferramenta está; se faltar uma linha, ela não está instalada |
| `oc version --client` | versão do `oc`, sem contatar o cluster |

## 2. Quem eu sou para o cluster — Leitura

```bash
printenv KUBECONFIG
oc whoami
oc whoami --show-server
oc whoami --show-context
oc auth can-i '*' '*' --all-namespaces
```

| Comando | O que faz |
|---|---|
| `printenv KUBECONFIG` | qual arquivo de credenciais o `oc` está usando |
| `oc whoami` | sua identidade no cluster |
| `--show-server` | endereço da API (`https://api.ocp.example.lab:6443`) |
| `--show-context` | nome do contexto atual |
| `oc auth can-i '*' '*' --all-namespaces` | `yes` = você tem poder total (cluster-admin) |

> Se `oc whoami` responder `system:admin`, o terminal está com a chave de **recuperação** do instalador. Para
> praticar, use um perfil próprio (seção 3).

## 3. Um kubeconfig para cada perfil — Altera (só arquivos em `~/.kube`)

```bash
mkdir -p ~/.kube && chmod 700 ~/.kube

# CA da API (certificado público, não é segredo)
oc get configmap kube-root-ca.crt -n default -o jsonpath='{.data.ca\.crt}' > ~/.kube/ocp-sno-ca.crt

# Perfil developer
export KUBECONFIG=$HOME/.kube/ac-developer.kubeconfig
oc login https://api.ocp.example.lab:6443 -u developer --certificate-authority=$HOME/.kube/ocp-sno-ca.crt
chmod 600 $KUBECONFIG
oc whoami

# Perfil admin
export KUBECONFIG=$HOME/.kube/ac-admin.kubeconfig
oc login https://api.ocp.example.lab:6443 -u admin --certificate-authority=$HOME/.kube/ocp-sno-ca.crt
chmod 600 $KUBECONFIG
oc whoami
```

| Comando | O que faz |
|---|---|
| `export KUBECONFIG=...` | escolhe **antes** em qual arquivo o login será gravado |
| `oc login <url> -u <usuário>` | autentica; a senha é pedida no prompt (nunca digite a senha no comando) |
| `--certificate-authority=` | valida o certificado da API; se der erro `x509`, faça o login sem essa opção e aceite o modo inseguro (só no HomeLab) |
| `chmod 600` | só você lê o arquivo |

Trocar de perfil depois:

```bash
export KUBECONFIG=$HOME/.kube/ac-developer.kubeconfig   # developer
export KUBECONFIG=$HOME/.kube/ac-admin.kubeconfig       # admin
oc whoami                                              # confirma
```

Senhas de treino (só neste HomeLab): `developer` / `developer` e `admin` / `redhatocp`.

## 4. A API está de pé? — Leitura (qualquer perfil)

```bash
oc get --raw /readyz; echo
oc get --raw /livez; echo
oc get --raw '/readyz?verbose'
oc get --raw /version | jq -r .gitVersion
curl -ksS https://api.ocp.example.lab:6443/readyz; echo
```

| Comando | O que faz |
|---|---|
| `/readyz` | `ok` = API pronta para atender |
| `/livez` | `ok` = processo da API vivo |
| `'/readyz?verbose'` | lista cada verificação interna: `[+]` passou, `[-]` falhou |
| `/version` | versão do Kubernetes do servidor |
| `curl -ksS` | mesmo teste sem o `oc` (`-k` ignora o certificado, `-sS` só mostra erros) |

## 5. Saúde do cluster — Leitura (perfil admin)

```bash
oc get clusterversion
oc get nodes -o wide
oc get co
oc get co --no-headers | awk '$3!="True" || $4!="False" || $5!="False"'
oc adm top nodes
oc describe node ocp-sno.ocp.example.lab | sed -n '/Allocated resources:/,/Events:/p'
oc get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded
```

| Comando | O que faz |
|---|---|
| `oc get clusterversion` | versão do OpenShift; o ideal é `AVAILABLE=True` e `PROGRESSING=False` |
| `oc get nodes -o wide` | o nó único, com IP e versão; deve estar `Ready` |
| `oc get co` | Cluster Operators (os componentes da plataforma) |
| `awk '$3!="True" ...'` | mostra **só** os operadores fora do ideal (saída vazia = tudo bem) |
| `oc adm top nodes` | uso real de CPU e memória |
| `describe node ... Allocated resources` | quanto os pods **reservaram** (é isso que o agendador usa) |
| `--field-selector=status.phase!=Running,...` | pods com problema em todo o cluster |

> Se a memória estiver acima de ~85%, não comece exercícios que criem pods.

## 6. Pensar antes de alterar — Leitura

```bash
oc auth can-i create projectrequests
oc auth can-i delete pods -n ac00-orientacao
oc auth can-i delete nodes
oc auth can-i --list -n ac00-orientacao
```

| Comando | O que faz |
|---|---|
| `oc auth can-i <verbo> <recurso>` | pergunta à API se você **poderia** fazer a ação, sem fazê-la |
| `--list` | tudo o que você pode fazer no projeto |

| Risco | Exemplos | Regra |
|---|---|---|
| Leitura | `get`, `describe`, `explain`, `can-i` | livre |
| Altera (projeto de treino) | criar ou apagar objetos em `ac00-orientacao` | sempre com rótulo e limpeza |
| **Proibido no SNO** | `oc adm drain`, `oc adm cordon`, `oc adm upgrade`, mexer em `openshift-*`, `oc whoami -t` em tela | não executar |

## 7. Projeto de treino — Altera (só o projeto `ac00-orientacao`)

Como `developer`:

```bash
oc new-project ac00-orientacao --display-name='Academia 00 - Orientação'
oc project -q
oc get project ac00-orientacao -o jsonpath='{.metadata.annotations.openshift\.io/requester}{"\n"}'
oc get rolebindings -n ac00-orientacao
```

| Comando | O que faz |
|---|---|
| `oc new-project` | cria o projeto; quem cria vira administrador **dentro** dele |
| `oc project -q` | só o nome do projeto atual |
| `openshift.io/requester` | quem pediu o projeto |
| `oc get rolebindings` | quem tem qual papel no projeto |

Como `admin`, coloque um teto de recursos no projeto (o arquivo está em `manifests/`; faça o `git clone` antes):

```bash
oc apply --dry-run=server -f manifests/baseline-seguro/quota-limitrange.yaml -n ac00-orientacao
oc apply -f manifests/baseline-seguro/quota-limitrange.yaml -n ac00-orientacao
oc label namespace ac00-orientacao academy.openshift.dev/managed-by=academia
oc describe resourcequota ac-quota -n ac00-orientacao
```

| Comando | O que faz |
|---|---|
| `--dry-run=server` | a API valida tudo, mas **não grava** |
| `oc apply -f` | cria ou atualiza o que está no arquivo |
| `oc label namespace` | marca o namespace como da Academia (só o admin pode) |
| `oc describe resourcequota` | mostra o uso (`Used`) e o limite (`Hard`) de cada recurso |

## 8. Criar, conferir e apagar com segurança — Altera (só no projeto de treino)

```bash
oc create configmap ac00-cfg --from-literal=MODO=treino -n ac00-orientacao --dry-run=client -o yaml
oc create configmap ac00-cfg --from-literal=MODO=treino -n ac00-orientacao
oc label configmap ac00-cfg academy.openshift.dev/managed-by=academia -n ac00-orientacao
oc get configmap -n ac00-orientacao -l academy.openshift.dev/managed-by=academia
oc delete configmap -l academy.openshift.dev/managed-by=academia -n ac00-orientacao
```

| Comando | O que faz |
|---|---|
| `--dry-run=client -o yaml` | mostra o objeto que **seria** criado, sem contatar a API |
| `oc create configmap ... --from-literal` | cria um ConfigMap com uma chave e um valor |
| `oc label` | coloca o rótulo da Academia (é por ele que a limpeza encontra o que é seu) |
| `-l chave=valor` | filtra por rótulo |
| `oc delete ... -l ... -n ...` | apaga só o que tem o rótulo, só naquele projeto |

## 9. Encerrar a trilha — Altera

```bash
oc delete project ac00-orientacao
oc get project ac00-orientacao          # repita até aparecer NotFound
```

| Comando | O que faz |
|---|---|
| `oc delete project` | apaga o projeto e tudo dentro dele (leva alguns segundos) |
| `oc get project` | `Terminating` = ainda apagando; `NotFound` = terminou |

> Nunca apague projetos que não comecem com `ac`. Nunca remova *finalizers* para "acelerar".
