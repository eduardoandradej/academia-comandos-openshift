# Guia direto de comandos

Uma página por trilha, com **os comandos e a explicação lado a lado**: copie, rode e entenda, sem abrir pastas.
Cada página vai do básico ao avançado e termina com a limpeza do projeto de treino.

| Página | Assunto |
|---|---|
| [00 — Orientação e segurança](00-orientacao.md) | onde estou, quem sou, perfis, saúde do cluster, projeto de treino |
| [01 — Navegação e CLI](01-cli.md) | versões, ajuda, login/logout, kubeconfig, projetos, contextos |
| [02 — Leitura e inspeção](02-consultas.md) | `get`, `describe`, `explain`, filtros, JSONPath, jq, eventos |
| [03 — Projetos e metadados](03-projetos.md) | rótulos, anotações, seletores, donos, finalizers |
| [04 — Pods e contêineres](04-pods.md) | criar pods, logs, exec, rsh, cp, port-forward, debug, QoS, erros comuns |
| [05 — Deployments e workloads](05-deployments.md) | criar, escalar, rollout, undo, restart, set, estratégias, Jobs, CronJobs, DaemonSet |
| [06 — Services e DNS](06-servicos.md) | criar Services, portas, endpoints, DNS interno, azul/verde, headless, diagnóstico |
| [07 — Routes e Ingress](07-rotas.md) | Routes HTTP, hostname, caminhos, HTTPS edge/passthrough, pesos, Ingress, diagnóstico |
| [08 — ConfigMaps e Secrets](08-config.md) | criar ConfigMaps e Secrets, variáveis, arquivos, subPath, TLS, pull secret, imutáveis, extract, quem lê Secrets |

Regras rápidas:

- Rode na `ocp-admin`, como `student`.
- Use o perfil `developer`, salvo quando a seção pedir `admin`.
- Altere objetos só em projetos de treino (nomes começando com `ac`).
- Nunca rode `oc adm drain`, `oc adm cordon` ou `oc adm upgrade`, nem altere nada em `openshift-*`.

Quer praticar com desafios, falhas provocadas e gabaritos? Cada página aponta para os exercícios completos da trilha.
