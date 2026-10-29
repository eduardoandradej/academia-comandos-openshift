# Simulados

> Sessões cronometradas que juntam várias competências em uma prova **prática e original** da Academia.
> São **autoavaliação**: um script confere cada requisito e responde `OK`/`FALHA`, sem nota nem aprovação.

## Regras dos simulados

- Os enunciados são **escritos pela Academia**. Eles cobrem as áreas dos objetivos **públicos** de administração do
  OpenShift, mas não reproduzem questões, nomes, valores nem o sistema de correção de nenhum exame. Material que
  circula como "questões reais" de prova viola o acordo de confidencialidade do exame e não é usado aqui.
- Tudo acontece em projetos `ac-sim-*` e em objetos de cluster com nomes `sim-*`/`academia-*`, rotulados e com
  reversão descrita.
- Tarefas de escopo de cluster são **VERMELHAS e manuais**: você digita cada comando, com backup antes e reversão
  logo depois. Nenhum script da Academia altera OAuth, papéis de cluster, modelo de projeto ou operadores.
- A remoção do `kubeadmin` **nunca** é executada: no simulado ela vira um plano escrito.

## Simulados disponíveis

| ID | Tema | Duração | Tarefas | Perfil |
|---|---|---|---|---|
| [SIM-01](sim-01/README.md) | administração do cluster: identidade, RBAC, limites, rotas TLS, dados de aplicação, Helm, SCC, diagnóstico, rede, modelo de projeto, operadores, CronJob, quotas | 3 h | 17 | developer + admin |

Gabaritos: [`solucoes/simulados/`](../solucoes/simulados/README.md).
