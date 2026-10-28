# Guia direto 01 — Navegação e CLI

> Perfil: `developer` (`export KUBECONFIG=$HOME/.kube/ac-developer.kubeconfig`). Projeto de treino: `ac01-cli`.
> Exercícios completos: [trilhas/01-cli](../trilhas/01-cli/README.md).

## 1. Versões — Leitura

```bash
oc version
oc version --client
oc version -o json | jq -r .serverVersion.gitVersion
kubectl version --client
```

| Comando | O que faz |
|---|---|
| `oc version` | versão do cliente e do servidor |
| `--client` | só o cliente, sem contatar a API (separa problema de cliente de problema de cluster) |
| `-o json \| jq -r ...` | extrai um campo específico |
| `kubectl version --client` | versão do `kubectl` |

## 2. Ajuda sem sair do terminal — Leitura

```bash
oc help
oc get --help
oc get --help | sed -n '/Examples:/,/Options:/p'
oc options
oc get --help | grep -- --sort-by
```

| Comando | O que faz |
|---|---|
| `oc help` | lista todos os subcomandos |
| `oc <cmd> --help` | descrição, exemplos e opções de um subcomando |
| `sed -n '/Examples:/,/Options:/p'` | mostra só os exemplos |
| `oc options` | opções que valem para **todos** os comandos (`-n`, `--context`, `--request-timeout`...) |
| `grep -- --flag` | procura uma opção na ajuda |

## 3. Autocompletar (TAB) — Altera (arquivo no seu home)

```bash
source <(oc completion bash)
mkdir -p ~/.local/share/bash-completion/completions
oc completion bash > ~/.local/share/bash-completion/completions/oc
kubectl completion bash > ~/.local/share/bash-completion/completions/kubectl
```

| Comando | O que faz |
|---|---|
| `source <(oc completion bash)` | ativa o TAB só nesta sessão |
| `oc completion bash > ...` | ativa de forma permanente (vale a partir do próximo terminal) |

Teste: `oc get dep<TAB>` vira `oc get deployments`.

## 4. Login e logout — Altera (token de sessão)

```bash
export KUBECONFIG=$HOME/.kube/ac-developer.kubeconfig
oc login -u developer
oc whoami
oc logout
oc whoami                   # erro esperado: Unauthorized
oc login -u developer
```

| Comando | O que faz |
|---|---|
| `oc login -u <usuário>` | autentica no servidor do contexto atual; a senha é pedida no prompt |
| `oc logout` | encerra a sessão e invalida o token no servidor |
| `Unauthorized` | sessão inválida ou expirada (os tokens duram 24 h por padrão) |

## 5. Quem sou, sem revelar segredos — Leitura

```bash
oc whoami
oc whoami --show-server
oc whoami --show-context
oc whoami --show-console
oc auth whoami
oc whoami -t | wc -c
```

| Comando | O que faz |
|---|---|
| `--show-console` | endereço da Console Web |
| `oc auth whoami` | usuário **e grupos** |
| `oc whoami -t \| wc -c` | prova que existe um token sem mostrá-lo (**nunca** rode `oc whoami -t` sozinho em tela compartilhada) |

## 6. Ler o kubeconfig com segurança — Leitura

```bash
oc config get-contexts
oc config current-context
oc config view --minify
oc config view --minify -o jsonpath='{.clusters[0].cluster.server}{"\n"}'
oc config view --minify -o jsonpath='{.contexts[0].context.namespace}{"\n"}'
```

| Comando | O que faz |
|---|---|
| `get-contexts` | lista os contextos; o `*` marca o atual |
| `view --minify` | mostra só o contexto atual, **escondendo** tokens e certificados |
| `-o jsonpath=...` | extrai um campo (servidor, namespace...) |

> Nunca use `oc config view --raw`: ele mostra as credenciais.

## 7. Projetos — Altera (só projetos `ac01-*`)

```bash
oc new-project ac01-cli --display-name='Academia 01 - CLI'
oc new-project ac01-cli-b --skip-config-write
oc projects
oc project -q
oc project ac01-cli-b
oc project ac01-cli
oc delete project ac01-cli-b
```

| Comando | O que faz |
|---|---|
| `oc new-project` | cria e passa a usar o projeto |
| `--skip-config-write` | cria sem trocar o projeto atual |
| `oc projects` | lista os projetos a que você tem acesso |
| `oc project <nome>` | troca de projeto |
| `oc project -q` | só o nome do projeto atual |

## 8. Em qual namespace o comando roda? — Leitura

```bash
oc get pods                                           # usa o namespace do contexto
oc get pods -n ac01-cli                               # -n sempre vence
oc config set-context --current --namespace=ac01-cli  # muda o padrão do contexto atual
```

| Regra | Explicação |
|---|---|
| 1º | `-n` / `--namespace` no comando |
| 2º | namespace do contexto (definido por `oc project` ou `set-context`) |
| 3º | `default` |

Dica: em exercícios, sempre use `-n`.

## 9. Vários perfis no mesmo terminal — Leitura

```bash
export KUBECONFIG=$HOME/.kube/ac-developer.kubeconfig:$HOME/.kube/ac-admin.kubeconfig
oc config get-contexts
oc config rename-context "$(KUBECONFIG=$HOME/.kube/ac-developer.kubeconfig oc config current-context)" dev
oc config rename-context "$(KUBECONFIG=$HOME/.kube/ac-admin.kubeconfig oc config current-context)" adm
oc --context=dev whoami
oc --context=adm whoami
```

| Comando | O que faz |
|---|---|
| `KUBECONFIG=a:b` | junta os dois arquivos em memória |
| `rename-context` | dá nomes curtos aos contextos |
| `--context=<nome>` | usa outro contexto **só naquele comando** |

## 10. Resumo do projeto — Leitura

```bash
oc status -n ac01-cli
oc status --suggest -n ac01-cli
```

| Comando | O que faz |
|---|---|
| `oc status` | resumo do projeto: Services, Deployments, pods e como se ligam |
| `--suggest` | acrescenta recomendações |

## 11. Ver o que o `oc` faz por baixo — Leitura

```bash
oc get pods -n ac01-cli -v=6 2>&1 | grep GET
oc get --raw /api/v1/namespaces/ac01-cli/pods | jq -r '.items[].metadata.name'
oc get pods -n ac01-cli --request-timeout=5s
```

| Comando | O que faz |
|---|---|
| `-v=6` | mostra a URL e o código HTTP de cada chamada (não use `-v=8` ou mais: mostra dados) |
| `oc get --raw <caminho>` | faz a mesma chamada direto na API |
| `--request-timeout=5s` | desiste se a API não responder em 5 s |

## 12. Plugins — Altera (arquivo em `~/.local/bin`)

```bash
mkdir -p ~/.local/bin
printf '#!/usr/bin/env bash\necho "Olá, $(oc whoami)"\n' > ~/.local/bin/oc-ac-ola
chmod +x ~/.local/bin/oc-ac-ola
oc plugin list
oc ac-ola
rm -f ~/.local/bin/oc-ac-ola
```

| Comando | O que faz |
|---|---|
| arquivo `oc-<nome>` no PATH | vira o comando `oc <nome>` |
| `oc plugin list` | lista os plugins encontrados |

## 13. `oc` × `kubectl` — Leitura

```bash
oc get pods -n ac01-cli
kubectl get pods -n ac01-cli
kubectl get routes -n ac01-cli
```

| Só no `oc` | Equivalente no `kubectl` |
|---|---|
| `oc login` / `oc logout` | não existe |
| `oc new-project` | não existe diretamente |
| `oc project X` | `kubectl config set-context --current --namespace=X` |
| `oc whoami` | `kubectl auth whoami` |

## 14. Diagnóstico de conexão, camada por camada — Leitura

```bash
getent ahostsv4 api.ocp.example.lab
timeout 3 bash -c '</dev/tcp/api.ocp.example.lab/6443' && echo "porta aberta"
openssl s_client -connect api.ocp.example.lab:6443 -servername api.ocp.example.lab </dev/null 2>/dev/null | openssl x509 -noout -issuer -enddate
curl -ksS -o /dev/null -w '%{http_code}\n' https://api.ocp.example.lab:6443/readyz
oc whoami
```

| Camada | Comando | Mensagem quando falha |
|---|---|---|
| DNS | `getent ahostsv4` | `no such host` |
| Porta | `/dev/tcp/host/porta` | `connection refused` ou `i/o timeout` |
| Certificado | `openssl s_client` | `x509: certificate signed by unknown authority` |
| HTTP | `curl -w '%{http_code}'` | código diferente de 200 |
| Login | `oc whoami` | `Unauthorized` |

## 15. Encerrar a trilha — Altera

```bash
oc delete project ac01-cli
oc get project ac01-cli      # até NotFound
```
