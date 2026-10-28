# Índice de comandos

> Catálogo-semente com **235 formas** em 16 áreas (231 distintas: 4 duplicatas intencionais, marcadas na coluna Nota).
> Origem: catálogo inicial do projeto, enriquecido com perfil, trilha de destino, ficha e notas de compatibilidade.
> **Status de todos os itens: proposto.** Nenhum comando foi executado contra o cluster por este repositório;
> a validação acontece quando você o executa no seu HomeLab. Confira cada forma com `--help` no cliente 4.22.

**Risco:** VERDE = leitura/diagnóstico (168) · AMARELO = mutação reversível restrita a `ac*-*` (62) ·
VERMELHO = sensível, demonstrativo ou proibido de automatizar (5).

**Perfil:** `local` = sem cluster · `developer` = padrão · `admin` = administração de treino · `kvm-server`/`core@ocp-sno` = fora da `ocp-admin`, só leitura.

**Trilha:** onde o comando é (ou será) praticado. Trilhas 00–16 estão disponíveis; as demais são planejadas
(veja [trilhas/README.md](../trilhas/README.md)). Placeholders como `<ns>`, `<pod>` e `<nome>` devem ser substituídos.

Distribuição por trilha de destino: 00: 23, 01: 15, 02: 19, 03: 11, 04: 14, 05: 20, 06: 10, 07: 8, 08: 12, 09: 10, 10: 8, 11: 10, 12: 10, 13: 6, 14: 12, 15: 15, 16: 15, 17: 1, 18: 14, 19: 2.

## 01 — Acesso, versão e contexto

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 001 | `oc version --client` | Versão do cliente instalado | VERDE | local | [00](../trilhas/00-orientacao/README.md) | [oc-version](fichas/oc-version.md) |  |
| 002 | `oc version` | Cliente e servidor, se a API estiver disponível | VERDE | developer | [00](../trilhas/00-orientacao/README.md) | [oc-version](fichas/oc-version.md) |  |
| 003 | `oc whoami` | Identificar usuário autenticado | VERDE | developer | [00](../trilhas/00-orientacao/README.md) | [oc-whoami](fichas/oc-whoami.md) |  |
| 004 | `oc whoami --show-server` | Conferir endpoint API atual | VERDE | developer | [00](../trilhas/00-orientacao/README.md) | [oc-whoami](fichas/oc-whoami.md) |  |
| 005 | `oc whoami --show-context` | Conferir contexto corrente | VERDE | developer | [00](../trilhas/00-orientacao/README.md) | [oc-whoami](fichas/oc-whoami.md) |  |
| 006 | `oc whoami --show-token` | Revelar token de sessão; nunca publicar a saída | VERMELHO | developer | [01](../trilhas/01-cli/README.md) | [oc-whoami](fichas/oc-whoami.md) |  |
| 007 | `oc login https://api.ocp.example.lab:6443 -u developer` | Autenticação interativa de usuário de laboratório | AMARELO | developer | [01](../trilhas/01-cli/README.md) | [oc-login-logout](fichas/oc-login-logout.md) | senha só no prompt; definir KUBECONFIG do perfil antes (ORI-004) |
| 008 | `oc logout` | Encerrar token da sessão atual | AMARELO | developer | [01](../trilhas/01-cli/README.md) | [oc-login-logout](fichas/oc-login-logout.md) |  |
| 009 | `oc config get-contexts` | Listar contextos no kubeconfig | VERDE | developer | [01](../trilhas/01-cli/README.md) | [oc-config](fichas/oc-config.md) |  |
| 010 | `oc config current-context` | Contexto ativo | VERDE | developer | [01](../trilhas/01-cli/README.md) | [oc-config](fichas/oc-config.md) |  |
| 011 | `oc config view --minify` | Inspecionar definição do contexto corrente sem imprimir tokens | VERDE | developer | [01](../trilhas/01-cli/README.md) | [oc-config](fichas/oc-config.md) |  |
| 012 | `oc config use-context <contexto>` | Selecionar contexto (atenção ao cluster-alvo) | AMARELO | developer | [01](../trilhas/01-cli/README.md) | [oc-config](fichas/oc-config.md) |  |
| 013 | `oc config set-context --current --namespace=<ns>` | Definir namespace padrão do contexto atual | AMARELO | developer | [01](../trilhas/01-cli/README.md) | [oc-config](fichas/oc-config.md) |  |
| 014 | `oc project` | Mostrar projeto atual | VERDE | developer | [01](../trilhas/01-cli/README.md) | [oc-project](fichas/oc-project.md) |  |
| 015 | `oc projects` | Listar projetos acessíveis | VERDE | developer | [01](../trilhas/01-cli/README.md) | [oc-project](fichas/oc-project.md) |  |
| 016 | `oc status` | Resumo do projeto corrente | VERDE | developer | [01](../trilhas/01-cli/README.md) | [oc-status](fichas/oc-status.md) |  |
| 017 | `oc completion bash` | Gerar script de conclusão de comandos | VERDE | local | [01](../trilhas/01-cli/README.md) | [oc-help-completion-plugin](fichas/oc-help-completion-plugin.md) |  |
| 018 | `oc help` | Ajuda geral | VERDE | local | [01](../trilhas/01-cli/README.md) | [oc-help-completion-plugin](fichas/oc-help-completion-plugin.md) |  |
| 019 | `oc get --help` | Ajuda do subcomando de consulta | VERDE | local | [01](../trilhas/01-cli/README.md) | [oc-help-completion-plugin](fichas/oc-help-completion-plugin.md) |  |
| 020 | `oc options` | Flags globais | VERDE | local | [01](../trilhas/01-cli/README.md) | [oc-help-completion-plugin](fichas/oc-help-completion-plugin.md) |  |

## 02 — Observabilidade e APIs

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 021 | `oc api-resources` | Listar tipos de recurso disponíveis | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-api-resources](fichas/oc-api-resources.md) |  |
| 022 | `oc api-versions` | Listar grupos/versões de API | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-api-resources](fichas/oc-api-resources.md) |  |
| 023 | `oc explain deployment` | Ler esquema de um Deployment | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-explain](fichas/oc-explain.md) |  |
| 024 | `oc explain pod.spec.containers` | Explorar campo de pod | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-explain](fichas/oc-explain.md) |  |
| 025 | `oc explain deployment.spec.template.spec --recursive` | Inspecionar campos aninhados | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-explain](fichas/oc-explain.md) |  |
| 026 | `oc get pods -n <ns>` | Listar Pods de projeto de treino | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 027 | `oc get pods -n <ns> -o wide` | Ver IP e nó de agendamento | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 028 | `oc get pods -n <ns> -o yaml` | Inspecionar YAML completo | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 029 | `oc get pods -n <ns> -o json` | Inspecionar JSON completo | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 030 | `oc get pods -n <ns> -o name` | Listar nomes canônicos | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 031 | `oc get pods -n <ns> -l app=demo` | Selecionar Pods por label | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 032 | `oc get pods -n <ns> --field-selector=status.phase=Running` | Filtrar por campo do objeto | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 033 | `oc get deploy -n <ns> --show-labels` | Conferir etiquetas dos Deployments | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 034 | `oc get svc -n <ns> -o custom-columns=NAME:.metadata.name,PORT:.spec.ports[0].port` | Formatar colunas | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 035 | `oc get pods -n <ns> -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'` | Consultar JSONPath | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 036 | `oc describe pod <pod> -n <ns>` | Investigar status, eventos e ambiente | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-describe](fichas/oc-describe.md) |  |
| 037 | `oc get events -n <ns> --sort-by=.metadata.creationTimestamp` | Ordenar eventos | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get-events](fichas/oc-get-events.md) | mesma forma do 126 e do 206 (contextos diferentes) |
| 038 | `oc get pods -n <ns> -w` | Acompanhar mudanças em tempo real | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-get](fichas/oc-get.md) |  |
| 039 | `oc wait -n <ns> --for=condition=Available deploy/<nome> --timeout=120s` | Esperar Deployment disponível | VERDE | developer | [02](../trilhas/02-consultas/README.md) | [oc-wait](fichas/oc-wait.md) |  |
| 040 | `oc get --raw /readyz` | Consultar prontidão API via endpoint bruto | VERDE | developer | [00](../trilhas/00-orientacao/README.md) | [oc-get-raw](fichas/oc-get-raw.md) |  |
| 041 | `oc get --raw /livez` | Consultar vivacidade da API | VERDE | developer | [00](../trilhas/00-orientacao/README.md) | [oc-get-raw](fichas/oc-get-raw.md) |  |
| 042 | `oc get nodes -o wide` | Inspecionar cluster node | VERDE | admin | [00](../trilhas/00-orientacao/README.md) | [oc-get](fichas/oc-get.md) |  |
| 043 | `oc get clusterversion` | Estado da versão do cluster | VERDE | admin | [00](../trilhas/00-orientacao/README.md) | [oc-get](fichas/oc-get.md) |  |
| 044 | `oc get co` | Estado dos Cluster Operators | VERDE | admin | [00](../trilhas/00-orientacao/README.md) | [oc-get](fichas/oc-get.md) |  |

## 03 — Projetos, escopos e metadados

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 045 | `oc new-project ac03-projetos` | Criar namespace reservado de treino | AMARELO | developer | [03](../trilhas/03-projetos/README.md) | [oc-new-project](fichas/oc-new-project.md) |  |
| 046 | `oc create namespace ac03-extra` | Criar namespace Kubernetes adicional | AMARELO | admin | [03](../trilhas/03-projetos/README.md) | — |  |
| 047 | `oc get namespaces` | Listar namespaces | VERDE | developer | [03](../trilhas/03-projetos/README.md) | [oc-get](fichas/oc-get.md) |  |
| 048 | `oc describe namespace ac03-projetos` | Inspecionar namespace | VERDE | developer | [03](../trilhas/03-projetos/README.md) | — |  |
| 049 | `oc get resourcequota -n ac03-projetos` | Consultar cotas | VERDE | developer | [03](../trilhas/03-projetos/README.md) | — |  |
| 050 | `oc label namespace ac03-projetos purpose=training` | Adicionar label a namespace de treino | AMARELO | developer | [03](../trilhas/03-projetos/README.md) | [oc-label-annotate](fichas/oc-label-annotate.md) |  |
| 051 | `oc label namespace ac03-projetos purpose-` | Remover label específica | AMARELO | developer | [03](../trilhas/03-projetos/README.md) | [oc-label-annotate](fichas/oc-label-annotate.md) |  |
| 052 | `oc annotate namespace ac03-projetos owner=academia` | Adicionar anotação | AMARELO | developer | [03](../trilhas/03-projetos/README.md) | [oc-label-annotate](fichas/oc-label-annotate.md) |  |
| 053 | `oc annotate namespace ac03-projetos owner-` | Remover anotação | AMARELO | developer | [03](../trilhas/03-projetos/README.md) | [oc-label-annotate](fichas/oc-label-annotate.md) |  |
| 054 | `oc get all -n ac03-projetos` | Consultar recursos básicos do projeto | VERDE | developer | [03](../trilhas/03-projetos/README.md) | [oc-get](fichas/oc-get.md) |  |
| 055 | `oc delete namespace ac03-projetos` | Limpar somente namespace criado para este exercício, após confirmação | AMARELO | developer | [03](../trilhas/03-projetos/README.md) | — |  |

## 04 — Pods, execução e logs

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 056 | `oc run treino-nginx --image=registry.access.redhat.com/ubi9/httpd-24 -n <ns>` | Criar Pod simples, depois verificar compatibilidade de imagem/porta | AMARELO | developer | [04](../trilhas/04-pods/README.md) | [oc-run](fichas/oc-run.md) | httpd-24 escuta 8080; o nome do pod diz nginx, mas a imagem é httpd |
| 057 | `oc get pod treino-nginx -n <ns>` | Verificar ciclo de vida | VERDE | developer | [04](../trilhas/04-pods/README.md) | [oc-get](fichas/oc-get.md) |  |
| 058 | `oc describe pod treino-nginx -n <ns>` | Investigar eventos | VERDE | developer | [04](../trilhas/04-pods/README.md) | — |  |
| 059 | `oc logs pod/<pod> -n <ns>` | Logs atuais | VERDE | developer | [04](../trilhas/04-pods/README.md) | [oc-logs](fichas/oc-logs.md) |  |
| 060 | `oc logs -f pod/<pod> -n <ns>` | Seguir logs continuamente | VERDE | developer | [04](../trilhas/04-pods/README.md) | [oc-logs](fichas/oc-logs.md) |  |
| 061 | `oc logs pod/<pod> --previous -n <ns>` | Logs da instância anterior | VERDE | developer | [04](../trilhas/04-pods/README.md) | [oc-logs](fichas/oc-logs.md) |  |
| 062 | `oc logs deployment/<nome> -n <ns>` | Logs de Pod selecionado pelo Deployment | VERDE | developer | [04](../trilhas/04-pods/README.md) | [oc-logs](fichas/oc-logs.md) |  |
| 063 | `oc exec -it pod/<pod> -n <ns> -- /bin/sh` | Abrir shell, se disponível na imagem | AMARELO | developer | [04](../trilhas/04-pods/README.md) | [oc-exec-rsh](fichas/oc-exec-rsh.md) |  |
| 064 | `oc exec pod/<pod> -n <ns> -- id` | Inspecionar identidade do processo | VERDE | developer | [04](../trilhas/04-pods/README.md) | [oc-exec-rsh](fichas/oc-exec-rsh.md) |  |
| 065 | `oc rsh -n <ns> pod/<pod>` | Shell remoto com oc | AMARELO | developer | [04](../trilhas/04-pods/README.md) | [oc-exec-rsh](fichas/oc-exec-rsh.md) |  |
| 066 | `oc cp -n <ns> pod/<pod>:/tmp/arquivo ./arquivo` | Copiar arquivo do Pod | AMARELO | developer | [04](../trilhas/04-pods/README.md) | [oc-exec-rsh](fichas/oc-exec-rsh.md) |  |
| 067 | `oc attach -it pod/<pod> -n <ns>` | Anexar-se ao processo principal quando apropriado | AMARELO | developer | [04](../trilhas/04-pods/README.md) | [oc-exec-rsh](fichas/oc-exec-rsh.md) |  |
| 068 | `oc port-forward -n <ns> svc/<svc> 8080:8080` | Redirecionar serviço para máquina local | AMARELO | developer | [04](../trilhas/04-pods/README.md) | [oc-port-forward](fichas/oc-port-forward.md) |  |
| 069 | `oc delete pod treino-nginx -n <ns>` | Apagar somente Pod de treino | AMARELO | developer | [04](../trilhas/04-pods/README.md) | — |  |

## 05 — Deployments e rollout

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 070 | `oc create deployment demo --image=registry.access.redhat.com/ubi9/httpd-24 -n <ns>` | Criar Deployment | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-create-deployment-scale](fichas/oc-create-deployment-scale.md) |  |
| 071 | `oc new-app --image=registry.access.redhat.com/ubi9/httpd-24 -n <ns>` | Criar app a partir de imagem compatível | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-create-deployment-scale](fichas/oc-create-deployment-scale.md) |  |
| 072 | `oc get deploy -n <ns>` | Listar deployments | VERDE | developer | [05](../trilhas/05-deployments/README.md) | [oc-get](fichas/oc-get.md) |  |
| 073 | `oc describe deploy/demo -n <ns>` | Ver status e estratégia | VERDE | developer | [05](../trilhas/05-deployments/README.md) | — |  |
| 074 | `oc get rs -n <ns>` | Observar ReplicaSets | VERDE | developer | [05](../trilhas/05-deployments/README.md) | [oc-get](fichas/oc-get.md) |  |
| 075 | `oc scale deploy/demo --replicas=2 -n <ns>` | Escalar com teto de duas réplicas | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-create-deployment-scale](fichas/oc-create-deployment-scale.md) |  |
| 076 | `oc scale deploy/demo --replicas=1 -n <ns>` | Reduzir escala | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-create-deployment-scale](fichas/oc-create-deployment-scale.md) |  |
| 077 | `oc rollout status deploy/demo -n <ns>` | Acompanhar disponibilização | VERDE | developer | [05](../trilhas/05-deployments/README.md) | [oc-rollout](fichas/oc-rollout.md) |  |
| 078 | `oc rollout history deploy/demo -n <ns>` | Consultar revisões | VERDE | developer | [05](../trilhas/05-deployments/README.md) | [oc-rollout](fichas/oc-rollout.md) |  |
| 079 | `oc rollout history deploy/demo --revision=1 -n <ns>` | Ver detalhes da revisão 1 | VERDE | developer | [05](../trilhas/05-deployments/README.md) | [oc-rollout](fichas/oc-rollout.md) |  |
| 080 | `oc rollout restart deploy/demo -n <ns>` | Reiniciar rollout de app de treino | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-rollout](fichas/oc-rollout.md) |  |
| 081 | `oc rollout undo deploy/demo -n <ns>` | Desfazer última alteração do rollout | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-rollout](fichas/oc-rollout.md) |  |
| 082 | `oc rollout pause deploy/demo -n <ns>` | Suspender rollout de app de treino | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-rollout](fichas/oc-rollout.md) |  |
| 083 | `oc rollout resume deploy/demo -n <ns>` | Retomar rollout de app de treino | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-rollout](fichas/oc-rollout.md) |  |
| 084 | `oc set image deploy/demo <container>=<imagem>:<tag> -n <ns>` | Trocar imagem do container | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-set](fichas/oc-set.md) |  |
| 085 | `oc set resources deploy/demo --requests=cpu=50m,memory=64Mi --limits=cpu=200m,memory=256Mi -n <ns>` | Configurar requests/limits moderados | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-set](fichas/oc-set.md) |  |
| 086 | `oc set env deploy/demo MODO=treino -n <ns>` | Adicionar variável ambiente | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-set](fichas/oc-set.md) |  |
| 087 | `oc set env deploy/demo MODO- -n <ns>` | Remover variável ambiente | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | [oc-set](fichas/oc-set.md) |  |
| 088 | `oc get deployment demo -o yaml -n <ns>` | Inspecionar spec e status | VERDE | developer | [05](../trilhas/05-deployments/README.md) | [oc-get](fichas/oc-get.md) | mesma forma do 156 |
| 089 | `oc delete deployment demo -n <ns>` | Remover Deployment do exercício | AMARELO | developer | [05](../trilhas/05-deployments/README.md) | — |  |

## 06 — Service, Route e DNS

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 090 | `oc get services -n <ns>` | Listar Services | VERDE | developer | [06](../trilhas/06-servicos/README.md) | [oc-expose-service](fichas/oc-expose-service.md) |  |
| 091 | `oc expose deployment demo --port=8080 -n <ns>` | Gerar Service para Deployment | AMARELO | developer | [06](../trilhas/06-servicos/README.md) | [oc-expose-service](fichas/oc-expose-service.md) |  |
| 092 | `oc expose svc/demo -n <ns>` | Criar Route HTTP | AMARELO | developer | [07](../trilhas/07-rotas/README.md) | [oc-route](fichas/oc-route.md) |  |
| 093 | `oc get routes -n <ns>` | Ver rotas externas | VERDE | developer | [07](../trilhas/07-rotas/README.md) | [oc-route](fichas/oc-route.md) |  |
| 094 | `oc describe route demo -n <ns>` | Ver destino/terminação | VERDE | developer | [07](../trilhas/07-rotas/README.md) | [oc-route](fichas/oc-route.md) |  |
| 095 | `oc get endpoints -n <ns>` | Ver endpoints legados | VERDE | developer | [06](../trilhas/06-servicos/README.md) | [oc-expose-service](fichas/oc-expose-service.md) | Endpoints está obsoleto em favor de EndpointSlice nas versões recentes do Kubernetes; preferir 096 |
| 096 | `oc get endpointslices -n <ns>` | Ver EndpointSlices | VERDE | developer | [06](../trilhas/06-servicos/README.md) | [oc-expose-service](fichas/oc-expose-service.md) |  |
| 097 | `oc get svc/demo -o yaml -n <ns>` | Inspecionar selector e targetPort | VERDE | developer | [06](../trilhas/06-servicos/README.md) | [oc-expose-service](fichas/oc-expose-service.md) |  |
| 098 | `oc get route demo -o jsonpath='{.spec.host}{"\n"}' -n <ns>` | Obter hostname da Route | VERDE | developer | [07](../trilhas/07-rotas/README.md) | [oc-route](fichas/oc-route.md) |  |
| 099 | `curl -vk https://console-openshift-console.apps.ocp.example.lab` | Testar HTTPS do Console e cadeia TLS | VERDE | local | [07](../trilhas/07-rotas/README.md) | — | no Windows sem wildcard no hosts, cada Route precisa de entrada própria |
| 100 | `curl -ksS https://api.ocp.example.lab:6443/readyz` | Testar prontidão da API | VERDE | local | [06](../trilhas/06-servicos/README.md) | — | mesma forma do 224 |
| 101 | `dig @192.168.10.25 api.ocp.example.lab A +short` | Consultar DNS local | VERDE | local | [06](../trilhas/06-servicos/README.md) | — |  |
| 102 | `dig @192.168.10.25 console-openshift-console.apps.ocp.example.lab A +short` | Consultar DNS wildcard | VERDE | local | [06](../trilhas/06-servicos/README.md) | — |  |
| 103 | `getent ahostsv4 api.ocp.example.lab` | Testar resolvedor do cliente | VERDE | local | [06](../trilhas/06-servicos/README.md) | — |  |
| 104 | `oc get networkpolicy -n <ns>` | Consultar políticas de rede | VERDE | developer | [06](../trilhas/06-servicos/README.md) | — | mesma forma do 192 |

## 07 — ConfigMaps, Secrets e service accounts

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 105 | `oc create configmap cfg-demo --from-literal=MODE=lab -n <ns>` | Criar ConfigMap de teste | AMARELO | developer | [08](../trilhas/08-config/README.md) | [oc-configmap-secret](fichas/oc-configmap-secret.md) |  |
| 106 | `oc create configmap cfg-demo --from-file=app.conf -n <ns> --dry-run=client -o yaml` | Gerar YAML sem alterar o cluster | VERDE | developer | [08](../trilhas/08-config/README.md) | [oc-configmap-secret](fichas/oc-configmap-secret.md) |  |
| 107 | `oc get configmap -n <ns>` | Listar ConfigMaps | VERDE | developer | [08](../trilhas/08-config/README.md) | [oc-get](fichas/oc-get.md) |  |
| 108 | `oc describe configmap cfg-demo -n <ns>` | Inspecionar configuração sem segredo | VERDE | developer | [08](../trilhas/08-config/README.md) | [oc-configmap-secret](fichas/oc-configmap-secret.md) |  |
| 109 | `oc create secret generic secret-demo --from-literal=DEMO=valor-ficticio -n <ns>` | Criar Secret com valor sem sensibilidade apenas em ambiente controlado | AMARELO | developer | [08](../trilhas/08-config/README.md) | [oc-configmap-secret](fichas/oc-configmap-secret.md) |  |
| 110 | `oc get secret -n <ns>` | Listar metadados dos Secrets (não exibir dados) | VERDE | developer | [08](../trilhas/08-config/README.md) | [oc-get](fichas/oc-get.md) |  |
| 111 | `oc set env deploy/demo --from=configmap/cfg-demo -n <ns>` | Injetar parâmetros não secretos | AMARELO | developer | [08](../trilhas/08-config/README.md) | [oc-set-volume](fichas/oc-set-volume.md) |  |
| 112 | `oc create serviceaccount sa-demo -n <ns>` | Criar SA dedicada | AMARELO | developer | [08](../trilhas/08-config/README.md) | — |  |
| 113 | `oc get sa -n <ns>` | Listar serviceaccounts | VERDE | developer | [08](../trilhas/08-config/README.md) | [oc-get](fichas/oc-get.md) |  |
| 114 | `oc set serviceaccount deployment/demo sa-demo -n <ns>` | Associar SA ao Deployment | AMARELO | developer | [08](../trilhas/08-config/README.md) | [oc-set](fichas/oc-set.md) |  |
| 115 | `oc delete configmap cfg-demo -n <ns>` | Limpar ConfigMap do treino | AMARELO | developer | [08](../trilhas/08-config/README.md) | [oc-configmap-secret](fichas/oc-configmap-secret.md) |  |
| 116 | `oc delete secret secret-demo -n <ns>` | Limpar Secret fictício | AMARELO | developer | [08](../trilhas/08-config/README.md) | [oc-configmap-secret](fichas/oc-configmap-secret.md) |  |

## 08 — Volumes e persistência (dependente de pré-requisito)

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 117 | `oc get storageclass` | Descobrir classes disponíveis | VERDE | admin | [09](../trilhas/09-storage/README.md) | [oc-pvc-storage](fichas/oc-pvc-storage.md) |  |
| 118 | `oc get pvc -A` | Listar PVCs em todos namespaces (somente leitura) | VERDE | admin | [09](../trilhas/09-storage/README.md) | [oc-get](fichas/oc-get.md) |  |
| 119 | `oc get pv` | Listar PVs do cluster | VERDE | admin | [09](../trilhas/09-storage/README.md) | [oc-pvc-storage](fichas/oc-pvc-storage.md) |  |
| 120 | `oc explain persistentvolumeclaim.spec` | Explorar esquema PVC | VERDE | developer | [09](../trilhas/09-storage/README.md) | [oc-pvc-storage](fichas/oc-pvc-storage.md) |  |
| 121 | `oc get statefulset -n <ns>` | Consultar StatefulSets | VERDE | developer | [09](../trilhas/09-storage/README.md) | [oc-get](fichas/oc-get.md) |  |
| 122 | `oc describe pvc <pvc> -n <ns>` | Investigar Binding e provisionador | VERDE | developer | [09](../trilhas/09-storage/README.md) | [oc-pvc-storage](fichas/oc-pvc-storage.md) |  |
| 123 | `oc describe pv <pv>` | Inspecionar volume existente | VERDE | admin | [09](../trilhas/09-storage/README.md) | [oc-pvc-storage](fichas/oc-pvc-storage.md) |  |
| 124 | `oc get sc -o yaml` | Ler StorageClasses sem modificá-las | VERDE | admin | [09](../trilhas/09-storage/README.md) | [oc-pvc-storage](fichas/oc-pvc-storage.md) |  |
| 125 | `oc get pods -n <ns> -o jsonpath='{range .items[*]}{.metadata.name}{": "}{.spec.volumes[*].name}{"\n"}{end}'` | Inspecionar volumes usados por Pods | VERDE | developer | [09](../trilhas/09-storage/README.md) | — |  |
| 126 | `oc get events -n <ns> --sort-by=.metadata.creationTimestamp` | Investigar PVC Pending | VERDE | developer | [09](../trilhas/09-storage/README.md) | [oc-get-events](fichas/oc-get-events.md) | duplicata intencional do 037, no contexto de PVC Pending |

## 09 — Imagens, ImageStream e registry

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 127 | `oc get imagestream -n <ns>` | Listar ImageStreams | VERDE | developer | [10](../trilhas/10-imagens/README.md) | [oc-image-imagestream](fichas/oc-image-imagestream.md) |  |
| 128 | `oc create imagestream hello -n <ns>` | Criar ImageStream | AMARELO | developer | [10](../trilhas/10-imagens/README.md) | [oc-image-imagestream](fichas/oc-image-imagestream.md) |  |
| 129 | `oc get istag -n <ns>` | Listar tags de ImageStreams | VERDE | developer | [10](../trilhas/10-imagens/README.md) | [oc-image-imagestream](fichas/oc-image-imagestream.md) |  |
| 130 | `oc image info quay.io/redhattraining/hello-world-nginx:latest` | Inspecionar metadados da imagem, se pública | VERDE | developer | [10](../trilhas/10-imagens/README.md) | [oc-image-imagestream](fichas/oc-image-imagestream.md) |  |
| 131 | `oc import-image hello:latest --from=quay.io/redhattraining/hello-world-nginx:latest --confirm -n <ns>` | Importar referência se registry externo disponível | AMARELO | developer | [10](../trilhas/10-imagens/README.md) | [oc-image-imagestream](fichas/oc-image-imagestream.md) |  |
| 132 | `oc tag <referencia> hello:v1 -n <ns>` | Definir tag, se fonte acessível | AMARELO | developer | [10](../trilhas/10-imagens/README.md) | [oc-image-imagestream](fichas/oc-image-imagestream.md) |  |
| 133 | `oc set image-lookup hello -n <ns>` | Habilitar lookup de ImageStream | AMARELO | developer | [10](../trilhas/10-imagens/README.md) | [oc-image-imagestream](fichas/oc-image-imagestream.md) |  |
| 134 | `oc set image-lookup -n <ns>` | Listar estado do lookup | VERDE | developer | [10](../trilhas/10-imagens/README.md) | [oc-image-imagestream](fichas/oc-image-imagestream.md) |  |
| 135 | `oc get configs.imageregistry.operator.openshift.io cluster -o yaml` | Inspecionar política do registry interno, sem alterar | VERDE | admin | 18 | [oc-image-imagestream](fichas/oc-image-imagestream.md) |  |
| 136 | `oc get image -o name` | Listar objetos de imagem globais | VERDE | admin | 18 | [oc-image-imagestream](fichas/oc-image-imagestream.md) |  |
| 137 | `oc get imagecontentsourcepolicy` | Detectar ICSP legados se presente | VERDE | admin | 18 | [oc-image-imagestream](fichas/oc-image-imagestream.md) | ICSP é legado; em 4.x recentes procurar também imagedigestmirrorsets/imagetagmirrorsets (veja TS-007) |

## 10 — Resiliência, métricas e escalonamento

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 138 | `oc adm top nodes` | Uso de CPU e memória do nó | VERDE | admin | [11](../trilhas/11-resiliencia/README.md) | [oc-set-probe-autoscale](fichas/oc-set-probe-autoscale.md) |  |
| 139 | `oc adm top pods -n <ns>` | Uso de recursos por Pod | VERDE | developer | [11](../trilhas/11-resiliencia/README.md) | [oc-set-probe-autoscale](fichas/oc-set-probe-autoscale.md) |  |
| 140 | `oc describe node ocp-sno.ocp.example.lab` | Allocatable, Capacity, condições e eventos | VERDE | admin | [11](../trilhas/11-resiliencia/README.md) | [oc-describe](fichas/oc-describe.md) |  |
| 141 | `oc set probe deploy/demo --readiness --get-url=http://:8080/ -n <ns>` | Exemplo de readiness; conferir sintaxe e porta do contêiner | AMARELO | developer | [11](../trilhas/11-resiliencia/README.md) | [oc-set-probe-autoscale](fichas/oc-set-probe-autoscale.md) | a página padrão do httpd da UBI responde 403 em /; use tcpSocket ou um caminho que exista |
| 142 | `oc set probe deploy/demo --liveness --get-url=http://:8080/ -n <ns>` | Exemplo de liveness; validar com imagem adequada | AMARELO | developer | [11](../trilhas/11-resiliencia/README.md) | [oc-set-probe-autoscale](fichas/oc-set-probe-autoscale.md) | mesma observação do 141 |
| 143 | `oc autoscale deploy/demo --min=1 --max=2 --cpu-percent=75 -n <ns>` | HPA limitado ao laboratório, se metrics estiverem disponíveis | AMARELO | developer | [11](../trilhas/11-resiliencia/README.md) | [oc-set-probe-autoscale](fichas/oc-set-probe-autoscale.md) | depende da Metrics API; teto de 2 réplicas |
| 144 | `oc get hpa -n <ns>` | Listar autoscalers | VERDE | developer | [11](../trilhas/11-resiliencia/README.md) | [oc-get](fichas/oc-get.md) |  |
| 145 | `oc describe hpa demo -n <ns>` | Ver métricas e decisões | VERDE | developer | [11](../trilhas/11-resiliencia/README.md) | [oc-set-probe-autoscale](fichas/oc-set-probe-autoscale.md) |  |
| 146 | `oc get pdb -n <ns>` | Consultar PodDisruptionBudgets | VERDE | developer | [11](../trilhas/11-resiliencia/README.md) | [oc-get](fichas/oc-get.md) |  |
| 147 | `oc get pods -n <ns> -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount` | Contar reinícios | VERDE | developer | [11](../trilhas/11-resiliencia/README.md) | [oc-get](fichas/oc-get.md) |  |

## 11 — Declarativo, patch e differencing

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 148 | `oc create deployment demo --image=<imagem> --dry-run=client -o yaml` | Produzir manifest sem instalar | VERDE | local | [12](../trilhas/12-declarativo/README.md) | [oc-apply-patch-diff](fichas/oc-apply-patch-diff.md) |  |
| 149 | `oc apply --dry-run=client -f ./manifest.yaml` | Validar preparação local, quando aplicável | VERDE | local | [12](../trilhas/12-declarativo/README.md) | [oc-apply-patch-diff](fichas/oc-apply-patch-diff.md) |  |
| 150 | `oc apply --dry-run=server -f ./manifest.yaml -n <ns>` | Pedir validação no servidor sem persistir, quando autorizado | VERDE | developer | [12](../trilhas/12-declarativo/README.md) | [oc-apply-patch-diff](fichas/oc-apply-patch-diff.md) |  |
| 151 | `oc diff -f ./manifest.yaml -n <ns>` | Comparar estado desejado x real | VERDE | developer | [12](../trilhas/12-declarativo/README.md) | [oc-apply-patch-diff](fichas/oc-apply-patch-diff.md) |  |
| 152 | `oc apply -f ./manifest.yaml -n <ns>` | Aplicar recurso no namespace de treino | AMARELO | developer | [12](../trilhas/12-declarativo/README.md) | [oc-apply-patch-diff](fichas/oc-apply-patch-diff.md) |  |
| 153 | `oc create -f ./manifest.yaml -n <ns>` | Criar recurso que não existe | AMARELO | developer | [12](../trilhas/12-declarativo/README.md) | [oc-apply-patch-diff](fichas/oc-apply-patch-diff.md) |  |
| 154 | `oc replace -f ./manifest.yaml -n <ns>` | Substituir recurso existente (avaliar perda de fields) | AMARELO | developer | [12](../trilhas/12-declarativo/README.md) | [oc-apply-patch-diff](fichas/oc-apply-patch-diff.md) |  |
| 155 | `oc patch deployment demo -n <ns> --type=merge -p '{"spec":{"replicas":1}}'` | Aplicar patch merge em objeto de treino | AMARELO | developer | [12](../trilhas/12-declarativo/README.md) | [oc-apply-patch-diff](fichas/oc-apply-patch-diff.md) |  |
| 156 | `oc get deployment demo -n <ns> -o yaml` | Ver configuração resultante | VERDE | developer | [12](../trilhas/12-declarativo/README.md) | [oc-get](fichas/oc-get.md) | duplicata intencional do 088, após patch |
| 157 | `oc delete -f ./manifest.yaml -n <ns>` | Limpar exatamente recursos declarados no arquivo de treino | AMARELO | developer | [12](../trilhas/12-declarativo/README.md) | [oc-apply-patch-diff](fichas/oc-apply-patch-diff.md) |  |

## 12 — Templates, Kustomize e Helm

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 158 | `oc process --help` | Consultar sintaxe de templates | VERDE | developer | [13](../trilhas/13-kustomize/README.md) | [oc-kustomize-process](fichas/oc-kustomize-process.md) |  |
| 159 | `oc get templates -n <ns>` | Listar templates | VERDE | developer | [13](../trilhas/13-kustomize/README.md) | [oc-kustomize-process](fichas/oc-kustomize-process.md) |  |
| 160 | `oc process -f ./template.yaml -p NAME=demo -o yaml` | Renderizar template sem aplicar | VERDE | local | [13](../trilhas/13-kustomize/README.md) | [oc-kustomize-process](fichas/oc-kustomize-process.md) |  |
| 161 | `oc kustomize ./overlays/dev` | Renderizar Kustomize de desenvolvimento | VERDE | local | [13](../trilhas/13-kustomize/README.md) | [oc-kustomize-process](fichas/oc-kustomize-process.md) |  |
| 162 | `kubectl kustomize ./overlays/dev` | Forma alternativa de renderização | VERDE | local | [13](../trilhas/13-kustomize/README.md) | [oc-kustomize-process](fichas/oc-kustomize-process.md) |  |
| 163 | `oc apply -k ./overlays/dev -n <ns>` | Aplicar overlay de treino | AMARELO | developer | [13](../trilhas/13-kustomize/README.md) | [oc-kustomize-process](fichas/oc-kustomize-process.md) |  |
| 164 | `helm version` | Verificar cliente Helm (se instalado) | VERDE | local | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 165 | `helm repo list` | Listar repositórios Helm | VERDE | local | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 166 | `helm show values ./chart` | Ler valores padrão do chart local | VERDE | local | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 167 | `helm lint ./chart` | Verificar chart | VERDE | local | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 168 | `helm template demo ./chart --namespace <ns>` | Renderizar manifests sem instalar | VERDE | local | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 169 | `helm install demo ./chart --namespace <ns>` | Instalar chart controlado de treino | AMARELO | developer | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 170 | `helm list -n <ns>` | Listar releases instaladas | VERDE | developer | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 171 | `helm status demo -n <ns>` | Conferir status da release | VERDE | developer | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 172 | `helm upgrade demo ./chart -n <ns>` | Atualizar release de laboratório | AMARELO | developer | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 173 | `helm history demo -n <ns>` | Listar revisões | VERDE | developer | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 174 | `helm rollback demo 1 -n <ns>` | Voltar à revisão especificada | AMARELO | developer | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |
| 175 | `helm uninstall demo -n <ns>` | Limpar release de treino | AMARELO | developer | [14](../trilhas/14-helm/README.md) | [helm](fichas/helm.md) |  |

## 13 — RBAC, identidade e permissões

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 176 | `oc auth can-i get pods -n <ns>` | Verificar permissão atual | VERDE | admin | [15](../trilhas/15-rbac/README.md) | [oc-auth-can-i](fichas/oc-auth-can-i.md) |  |
| 177 | `oc auth can-i create deployments -n <ns> --as=developer` | Consultar permissão de outro usuário se autorização permitir | VERDE | admin | [15](../trilhas/15-rbac/README.md) | [oc-auth-can-i](fichas/oc-auth-can-i.md) |  |
| 178 | `oc auth can-i --list -n <ns>` | Listar permissões efetivas no projeto | VERDE | admin | [15](../trilhas/15-rbac/README.md) | [oc-auth-can-i](fichas/oc-auth-can-i.md) |  |
| 179 | `oc get oauth cluster -o yaml` | Inspecionar IdP, sem secrets | VERDE | admin | [15](../trilhas/15-rbac/README.md) | [oc-policy-rbac](fichas/oc-policy-rbac.md) |  |
| 180 | `oc get users` | Listar usuários do OpenShift | VERDE | admin | [15](../trilhas/15-rbac/README.md) | [oc-policy-rbac](fichas/oc-policy-rbac.md) |  |
| 181 | `oc get groups` | Listar grupos existentes | VERDE | admin | [15](../trilhas/15-rbac/README.md) | [oc-policy-rbac](fichas/oc-policy-rbac.md) |  |
| 182 | `oc get roles,rolebindings -n <ns>` | Listar controles de acesso no projeto | VERDE | admin | [15](../trilhas/15-rbac/README.md) | [oc-get](fichas/oc-get.md) |  |
| 183 | `oc get clusterroles,clusterrolebindings` | Consultar RBAC global | VERDE | admin | [15](../trilhas/15-rbac/README.md) | [oc-policy-rbac](fichas/oc-policy-rbac.md) |  |
| 184 | `oc adm groups new ac-dev-group` | Criar grupo dedicado de treino | AMARELO | admin | [15](../trilhas/15-rbac/README.md) | [oc-policy-rbac](fichas/oc-policy-rbac.md) |  |
| 185 | `oc adm groups add-users ac-dev-group developer` | Associar usuário de treino ao grupo | AMARELO | admin | [15](../trilhas/15-rbac/README.md) | [oc-policy-rbac](fichas/oc-policy-rbac.md) |  |
| 186 | `oc policy add-role-to-user view developer -n <ns>` | Dar leitura em projeto de treino | AMARELO | admin | [15](../trilhas/15-rbac/README.md) | [oc-policy-rbac](fichas/oc-policy-rbac.md) |  |
| 187 | `oc policy add-role-to-group edit ac-dev-group -n <ns>` | Dar edição no namespace reservado | AMARELO | admin | [15](../trilhas/15-rbac/README.md) | [oc-policy-rbac](fichas/oc-policy-rbac.md) |  |
| 188 | `oc adm policy add-cluster-role-to-user cluster-admin admin` | Alteração global sensível; não automatizar | VERMELHO | admin | [15](../trilhas/15-rbac/README.md) | [oc-policy-rbac](fichas/oc-policy-rbac.md) |  |
| 189 | `oc get rolebinding -n <ns> -o yaml` | Auditar bindings | VERDE | admin | [15](../trilhas/15-rbac/README.md) | [oc-get](fichas/oc-get.md) |  |
| 190 | `oc get securitycontextconstraints` | Inspecionar SCCs sem alterar | VERDE | admin | 17 | — |  |
| 191 | `oc adm policy who-can create pods -n <ns>` | Listar sujeitos autorizados por ação | VERDE | admin | [15](../trilhas/15-rbac/README.md) | [oc-policy-rbac](fichas/oc-policy-rbac.md) |  |

## 14 — Rede, TLS e isolamento

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 192 | `oc get networkpolicy -n <ns>` | Listar políticas de rede | VERDE | developer | [16](../trilhas/16-rede/README.md) | [oc-networkpolicy](fichas/oc-networkpolicy.md) | duplicata intencional do 104 |
| 193 | `oc describe networkpolicy <nome> -n <ns>` | Inspecionar regras ingress/egress | VERDE | developer | [16](../trilhas/16-rede/README.md) | [oc-networkpolicy](fichas/oc-networkpolicy.md) |  |
| 194 | `oc apply -f ./networkpolicy-demo.yaml -n <ns>` | Isolar somente pods etiquetados do treino | AMARELO | developer | [16](../trilhas/16-rede/README.md) | [oc-networkpolicy](fichas/oc-networkpolicy.md) |  |
| 195 | `oc get route <nome> -n <ns> -o yaml` | Inspecionar TLS na Route | VERDE | developer | [07](../trilhas/07-rotas/README.md) | [oc-route](fichas/oc-route.md) |  |
| 196 | `openssl s_client -connect 192.168.10.200:443 -servername console-openshift-console.apps.ocp.example.lab </dev/null` | Inspecionar certificado por SNI | VERDE | local | [07](../trilhas/07-rotas/README.md) | — |  |
| 197 | `curl -I -k https://console-openshift-console.apps.ocp.example.lab` | Cabeçalhos HTTP via TLS | VERDE | local | [07](../trilhas/07-rotas/README.md) | — |  |
| 198 | `oc get ingresscontroller -n openshift-ingress-operator` | Consultar Ingress Controllers | VERDE | admin | [16](../trilhas/16-rede/README.md) | — |  |
| 199 | `oc get clusteroperator ingress` | Verificar saúde do Ingress | VERDE | admin | [16](../trilhas/16-rede/README.md) | — |  |
| 200 | `oc get dns.operator/default -o yaml` | Consultar DNS Operator sem mudança | VERDE | admin | [16](../trilhas/16-rede/README.md) | — |  |
| 201 | `oc get network.operator cluster -o yaml` | Consultar configuração CNI global sem alteração | VERDE | admin | [16](../trilhas/16-rede/README.md) | [oc-networkpolicy](fichas/oc-networkpolicy.md) |  |

## 15 — Administração e diagnóstico do cluster

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 202 | `oc get clusterversion version -o yaml` | Inspecionar status de release | VERDE | admin | [00](../trilhas/00-orientacao/README.md) | [oc-get](fichas/oc-get.md) |  |
| 203 | `oc get co --no-headers` | Ver todos os operadores sem cabeçalho | VERDE | admin | [00](../trilhas/00-orientacao/README.md) | [oc-get](fichas/oc-get.md) |  |
| 204 | `oc describe co monitoring` | Mensagens e condições do operador | VERDE | admin | [00](../trilhas/00-orientacao/README.md) | [oc-describe](fichas/oc-describe.md) |  |
| 205 | `oc get pods -A -o wide` | Consultar pods em todos namespaces | VERDE | admin | [00](../trilhas/00-orientacao/README.md) | [oc-get](fichas/oc-get.md) |  |
| 206 | `oc get events -A --sort-by=.metadata.creationTimestamp` | Investigar incidentes globais | VERDE | admin | [00](../trilhas/00-orientacao/README.md) | [oc-get-events](fichas/oc-get-events.md) |  |
| 207 | `oc get mcp` | Consultar MachineConfigPools | VERDE | admin | 18 | [oc-get](fichas/oc-get.md) |  |
| 208 | `oc get mc` | Consultar MachineConfigs, sem editar | VERDE | admin | 18 | [oc-get](fichas/oc-get.md) |  |
| 209 | `oc get csr` | Inspecionar solicitações de certificados | VERDE | admin | 18 | [oc-get](fichas/oc-get.md) |  |
| 210 | `oc get subscription -A` | Consultar subscriptions OLM | VERDE | admin | 18 | [oc-get](fichas/oc-get.md) |  |
| 211 | `oc get csv -A` | Consultar ClusterServiceVersions | VERDE | admin | 18 | [oc-get](fichas/oc-get.md) |  |
| 212 | `oc get installplan -A` | Consultar planos de instalação de operadores | VERDE | admin | 18 | [oc-get](fichas/oc-get.md) |  |
| 213 | `oc get operatorgroups -A` | Consultar OperatorGroups | VERDE | admin | 18 | [oc-get](fichas/oc-get.md) |  |
| 214 | `oc get pods -n openshift-monitoring` | Ver stack de observabilidade | VERDE | admin | 18 | [oc-get](fichas/oc-get.md) |  |
| 215 | `oc get route console -n openshift-console` | Consultar host do Console | VERDE | admin | [00](../trilhas/00-orientacao/README.md) | [oc-get](fichas/oc-get.md) |  |
| 216 | `oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"="}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'` | Extrair condição Ready | VERDE | admin | [00](../trilhas/00-orientacao/README.md) | [oc-get](fichas/oc-get.md) |  |
| 217 | `oc adm inspect ns/openshift-monitoring --dest-dir=./coleta` | Coleta potencialmente volumosa/sensível; requer autorização e espaço | VERMELHO | admin | 18 | — | coleta volumosa e potencialmente sensível: autorização e espaço em disco antes |
| 218 | `oc adm drain ocp-sno.ocp.example.lab` | **NUNCA EXECUTAR** no SNO de laboratório único | VERMELHO | admin | 18 | — | NUNCA no SNO: drena o único nó e derruba o cluster |
| 219 | `oc adm upgrade` | **NUNCA EXECUTAR** automaticamente; somente planejar | VERMELHO | admin | 18 | — | somente planejamento; nunca em script |

## 16 — Ferramentas auxiliares e saúde do host

| # | Comando ou forma | Para que serve | Risco | Perfil | Trilha | Ficha | Nota |
|---:|---|---|---|---|---|---|---|
| 220 | `jq -r '.items[].metadata.name' < resources.json` | Filtrar nomes em JSON exportado | VERDE | local | [00](../trilhas/00-orientacao/README.md) | [jq](fichas/jq.md) |  |
| 221 | `python3 -m json.tool resources.json` | Validar/formatar JSON local | VERDE | local | [00](../trilhas/00-orientacao/README.md) | — |  |
| 222 | `command -v oc kubectl jq` | Checar ferramentas disponíveis | VERDE | local | [16](../trilhas/16-rede/README.md) | — |  |
| 223 | `printenv KUBECONFIG` | Conferir kubeconfig em uso sem revelar conteúdo | VERDE | local | [16](../trilhas/16-rede/README.md) | — |  |
| 224 | `curl -ksS https://api.ocp.example.lab:6443/readyz` | Conferir API externamente | VERDE | local | [16](../trilhas/16-rede/README.md) | — | duplicata intencional do 100 |
| 225 | `hostnamectl` | Identificação do sistema local | VERDE | local | [16](../trilhas/16-rede/README.md) | — |  |
| 226 | `ip -br addr` | Endereços de rede locais | VERDE | local | [16](../trilhas/16-rede/README.md) | — |  |
| 227 | `ip route` | Tabela de rotas local | VERDE | local | [16](../trilhas/16-rede/README.md) | — |  |
| 228 | `ss -tln` | Sockets TCP localmente | VERDE | local | [16](../trilhas/16-rede/README.md) | — |  |
| 229 | `chronyc tracking` | Condição de sincronização NTP local | VERDE | local | [16](../trilhas/16-rede/README.md) | — |  |
| 230 | `journalctl -b -u kubelet -n 50 --no-pager` | Logs kubelet quando conectado ao RHCOS | VERDE | core@ocp-sno (leitura) | 19 | — |  |
| 231 | `sudo crictl ps` | Contêineres CRI-O no RHCOS, somente leitura | VERDE | core@ocp-sno (leitura) | 19 | — |  |
| 232 | `virsh domstate ocp-sno` | Estado VM (executar no kvm-server) | VERDE | kvm-server | [00](../trilhas/00-orientacao/README.md) | — |  |
| 233 | `virsh domblklist ocp-sno` | Discos anexados à VM (kvm-server) | VERDE | kvm-server | [00](../trilhas/00-orientacao/README.md) | — |  |
| 234 | `df -h /var` | Espaço no SSD do host (kvm-server) | VERDE | kvm-server | [00](../trilhas/00-orientacao/README.md) | — |  |
| 235 | `qemu-img info /var/lib/libvirt/images/ocp-fast/ocp-sno.qcow2` | Metadados do disco com VM rodando, somente leitura; não executar check/convert a quente | VERDE | kvm-server | [00](../trilhas/00-orientacao/README.md) | — | somente info; nunca check/convert com a VM ligada |
