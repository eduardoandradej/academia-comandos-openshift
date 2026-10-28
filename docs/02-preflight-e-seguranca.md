# Preflight e segurança operacional

O cluster é **real e único**: não é efêmero, não tem outro nó e divide o host com os laboratórios RHCSA/DVI. A
Academia trata segurança como parte do exercício, não como rodapé.

## Semáforo de risco

| Cor | Definição | Exemplos | Regra |
|---|---|---|---|
| **VERDE** | leitura e diagnóstico | `oc get`, `describe`, `explain`, `auth can-i`, `/readyz` | livre |
| **AMARELO** | mutação reversível restrita a projetos `ac*-*` | `new-project acNN-*`, `apply` de manifestos do repositório, `scale` até 2 | rótulo da Academia + validação + limpeza |
| **VERMELHO** | cluster, host, segredos ou irreversível | `adm drain/cordon/upgrade`, alterar OAuth, `config view --raw`, `whoami -t` em tela | só com procedimento dedicado e autorização explícita; **nunca** em scripts |

O risco depende do alvo e da saída: `oc delete pod` em `ac02-consultas` é AMARELO; em `openshift-etcd`, VERMELHO.
`oc whoami -t` não altera nada, mas revela um token.

## Proibido automatizar (lista não exaustiva)

- `oc delete node`; `oc delete namespace`/`project` fora de `ac*-*`; qualquer mutação em `openshift-*` ou `kube-*`.
- `oc adm drain`, `oc adm cordon`, reboot do `ocp-sno`, `oc adm upgrade`, etcd, `machine-config`.
- Desativar operadores, remover o OAuth/IdP existente, apagar `kubeadmin`, conceder SCC `privileged` de forma ampla, alterar a rede do cluster.
- `oc delete -A`, `--all` sem namespace e rótulo, `oc apply -f` de manifesto não revisado (ou de URL).
- Cargas pesadas, laços infinitos, muitas réplicas, uso intenso do SSD.
- Instalar ODF ou outros serviços pesados sem planejamento.
- Commitar kubeconfig, tokens, pull secret, senhas reais, chaves ou logs com dados sigilosos.

## Convenções de laboratório

| Convenção | Valor |
|---|---|
| Nome de projeto | `acNN-<tema>` (ex.: `ac02-consultas`) ou `ac-<tema>` |
| Rótulo obrigatório | `academy.openshift.dev/managed-by=academia` |
| Rótulos auxiliares | `academy.openshift.dev/trilha=NN`, `academy.openshift.dev/cenario=ts-NNN` |
| Quota padrão | [`manifests/baseline-seguro/quota-limitrange.yaml`](../manifests/baseline-seguro/quota-limitrange.yaml) |
| Réplicas | no máximo 2 |
| Perfil padrão | `developer` |

## Mecanismos dos scripts

| Script | Modo | Proteções |
|---|---|---|
| `scripts/preflight.sh` / `academy doctor` | leitura | só `whoami`, `get`, `project -q`, `adm top`; timeout por requisição; SSH ao host só com `--kvm-ssh` |
| `scripts/status.sh` | leitura | só nomes e contagens; nunca dados de Secrets |
| `scripts/safe-cleanup.sh` | **simula por padrão** | regex de namespace `ac*-*`; seletor obrigatório `academy.openshift.dev/<k>=<v>`; recusa `-A`/`--all`; confirmação digitada; projeto só com prova de propriedade |
| `scripts/academy` | leitura | `start/check/finish` ainda não implementados (exigem testes de idempotência) |
| `scripts/perfis.sh` | local | só exporta `KUBECONFIG` |

Todos usam `set -euo pipefail`. Os testes offline em `tests/run-tests.sh` usam um `oc` simulado e verificam, entre
outras coisas, que preflight e doctor **não fazem nenhuma chamada mutável** e que o safe-cleanup recusa escopos indevidos.

## Checklist antes de qualquer exercício AMARELO

1. `oc whoami` → perfil certo?
2. `oc project -q` e `-n` explícito.
3. `scripts/preflight.sh` sem FALHA; memória do nó < 85% (perfil admin).
4. Manifesto revisado (`less`), `--dry-run=server`, `oc diff`.
5. Rótulo da Academia presente.
6. Plano de limpeza conhecido.

## Segredos

- O diretório `~/openshift-lab/ocp422-sno/install/` é sigiloso: não ler, copiar, imprimir nem commitar.
- Senhas de treino só no prompt — nunca como argumento (`oc login`, `htpasswd`).
- `.gitignore` bloqueia `*kubeconfig*`, `*pull-secret*`, `*kubeadmin-password*`, chaves, `.env*`, `*token*`.
- Vazou um token? `oc logout` na sessão correspondente revoga-o imediatamente. Veja [SECURITY.md](../SECURITY.md).
