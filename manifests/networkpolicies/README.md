# NetworkPolicies de treino (Trilha 16)

Políticas para os projetos `ac16-rede` (loja `web-azul`/`web-verde`, rótulo `app=loja`) e `ac16-vizinho`
(cliente `app=ac16-cliente`). Aplique **uma de cada vez**, como pedem os exercícios, e sempre com `-n`.

| Arquivo | Efeito | Exercício |
|---|---|---|
| `00-negar-entrada.yaml` | nega toda entrada no projeto | NET-003 |
| `10-permitir-mesmo-projeto.yaml` | libera entrada vinda do próprio projeto | NET-004 |
| `20-permitir-cliente-vizinho.yaml` | libera a loja só para o cliente do `ac16-vizinho` (AND), porta 8080 | NET-005 |
| `30-permitir-router.yaml` | libera a loja para o router (Routes), porta 8080 | NET-007 |
| `40-negar-saida.yaml` | nega toda saída (inclusive DNS) | NET-008 |
| `50-permitir-dns.yaml` | libera DNS do cluster (porta 5353 dos pods do `openshift-dns`) | NET-008 |
| `60-permitir-saida-loja.yaml` | clientes só falam com a loja, porta 8080 | NET-009 |

Políticas são **aditivas**: um pod selecionado por qualquer política de um tipo passa a aceitar só o que alguma delas
libera. Remover todas volta ao padrão aberto. Limpeza: `oc delete networkpolicy -l academy.openshift.dev/managed-by=academia -n <projeto>`.
