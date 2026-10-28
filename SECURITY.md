# Segurança

## Escopo

Este repositório é material de estudo para um HomeLab isolado. As senhas de treino citadas (`developer`,
`redhatocp`, `redhat`, `student`) são **públicas e inseguras** e não devem ser usadas em nenhum outro ambiente.

## Nunca publique

- kubeconfig (inclusive `~/.kube/ac-*.kubeconfig` e o do instalador);
- saída de `oc whoami -t`, `oc config view --raw` ou qualquer token (`sha256~...`);
- pull secret, `kubeadmin-password`, arquivos HTPasswd, chaves SSH/TLS privadas;
- saídas de `oc get secret ... -o yaml`, coletas de `must-gather`/`adm inspect`;
- diários pessoais de progresso.

O `.gitignore` bloqueia os padrões mais comuns e a CI procura assinaturas de segredos, mas a responsabilidade final é
de quem faz o commit: confira `git diff --staged` antes.

## Se algo vazou

1. **Token OAuth**: rode `oc logout` na sessão correspondente (revoga imediatamente). Faça um novo `oc login`.
2. **Senha de usuário de treino**: troque-a no HTPasswd (procedimento manual, VERMELHO).
3. **Pull secret ou credencial de cluster**: trate como incidente; gere uma nova no portal correspondente.
4. **No Git**: remover o arquivo em um novo commit **não** apaga o histórico. Reescrever histórico de `main` exige
   decisão explícita do mantenedor — abra uma issue sem incluir o segredo.

## Relatar um problema

Abra uma issue descrevendo o problema **sem** incluir o dado sensível. Para scripts que possam causar dano ao
cluster, descreva o comando e o cenário; correções têm prioridade.
