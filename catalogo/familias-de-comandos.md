# Famílias de comandos

> Mapa das famílias do catálogo, com as comparações que mais confundem. Cada família aponta para a trilha onde é
> praticada. Trilhas 00–02 estão disponíveis; as demais são planejadas.

## Visão geral

| Família | Comandos centrais | Trilha | Fichas |
|---|---|---|---|
| Sessão e contexto | `version`, `whoami`, `login`, `logout`, `config`, `project(s)`, `status` | 00, 01 | [whoami](fichas/oc-whoami.md), [login](fichas/oc-login-logout.md), [config](fichas/oc-config.md), [project](fichas/oc-project.md) |
| Consulta | `api-resources`, `explain`, `get`, `describe`, `events`, `wait`, `get --raw` | 02 | [get](fichas/oc-get.md), [describe](fichas/oc-describe.md), [explain](fichas/oc-explain.md) |
| Projetos e metadados | `new-project`, `label`, `annotate`, seletores, `ownerReferences`, finalizers | 00, 03 | [new-project](fichas/oc-new-project.md), [label/annotate](fichas/oc-label-annotate.md) |
| Pods e diagnóstico | `run`, `logs`, `exec`, `rsh`, `cp`, `attach`, `port-forward`, `debug` | 04 | [run](fichas/oc-run.md), [logs](fichas/oc-logs.md), [exec/rsh/cp/debug](fichas/oc-exec-rsh.md), [port-forward](fichas/oc-port-forward.md) |
| Aplicações | `create deployment`, `new-app`, `scale`, `rollout`, `set`, `create job/cronjob` | 05, 11 | [deployment/scale](fichas/oc-create-deployment-scale.md), [rollout](fichas/oc-rollout.md), [set](fichas/oc-set.md), [job/cronjob](fichas/oc-create-job-cronjob.md) |
| Rede | `expose`, `create service`, `set selector`, `get svc/route/endpointslices`, `curl`, `dig`, `openssl` | 06, 07, 16 | [expose/service](fichas/oc-expose-service.md) |
| Configuração e volumes | `create configmap/secret`, `set env`, `set volume`, `get pv,pvc,sc` | 08, 09 | — |
| Imagens | `image info`, `imagestream`, `tag`, `import-image` | 10 | — |
| Declarativo | `apply`, `create -f`, `replace`, `patch`, `diff`, `--dry-run` | 00, 12 | — |
| Empacotamento | `process`, `kustomize`, `helm` | 13, 14 | — |
| RBAC e administração | `auth can-i`, `policy`, `adm groups`, `get co/clusterversion`, OLM | 00, 15, 17, 18 | [auth can-i](fichas/oc-auth-can-i.md) |

## Comparações essenciais

### `get` × `describe` × `explain`

| | `oc get` | `oc describe` | `oc explain` |
|---|---|---|---|
| Responde | qual é o estado/valor | o que está acontecendo | o que o campo significa |
| Fonte | objeto na API | objeto + eventos + dados agregados | esquema OpenAPI |
| Para scripts | sim (`-o json/jsonpath/name`) | não | não |

### `create` × `apply` × `replace` × `patch` × `edit`

| Comando | Se o objeto não existe | Se existe | Idempotente | Quando usar |
|---|---|---|---|---|
| `create` | cria | erro `AlreadyExists` | não | primeira criação, imperativa |
| `apply` | cria | mescla com o que você declarou | sim | fluxo declarativo (manifesto é a verdade) |
| `replace` | erro | substitui o objeto inteiro | sim, com cuidado | quando o manifesto é completo (campos ausentes somem) |
| `patch` | erro | altera só os campos enviados | depende | mudança pontual e auditável |
| `edit` | erro | abre editor e grava | não | exploração; evite em procedimentos repetíveis |

### `--dry-run=client` × `--dry-run=server` × `diff`

| | client | server | `oc diff` |
|---|---|---|---|
| Contata a API | não | sim | sim |
| Valida esquema, defaults e admissão (quota, SCC) | não | sim | — |
| Mostra a diferença para o estado atual | não | não | sim (código 1 = há diferença) |

### Rótulo × anotação

| | Rótulo | Anotação |
|---|---|---|
| Seleciona (`-l`) | sim | não |
| Valor | curto e restrito (63 caracteres) | texto livre |
| Uso | identidade e agrupamento | descrição e configuração de controladores |

### `oc project` × `oc config set-context --current --namespace`

| | `oc project X` | `set-context --current --namespace=X` |
|---|---|---|
| Valida que o projeto existe e você tem acesso | sim | não |
| Cria contexto `X/servidor/usuário` | sim | não (altera o atual) |

### `oc` × `kubectl`

| | `oc` | `kubectl` |
|---|---|---|
| Recursos de API (inclui Route, Project) | sim | sim |
| `login`/`logout` OAuth | sim | não |
| `new-project`, `new-app`, `start-build`, `adm`, `policy` | sim | não |
| Mesmo kubeconfig | sim | sim |

### Formatos de saída

| Formato | Laços | Condições | Somas/agrupamentos | Dependência |
|---|---|---|---|---|
| `-o jsonpath` | `range` | filtros `?()` | não | nenhuma |
| `-o custom-columns` | implícito por item | não | não | nenhuma |
| `-o go-template` | `range` | `if`/`eq` | não | nenhuma |
| `-o json \| jq` | sim | sim | sim | `jq` |

### Comparações das trilhas futuras

Registradas aqui para orientar o estudo; serão aprofundadas e exercitadas na trilha indicada.

| Par | Diferença central | Trilha |
|---|---|---|
| Service × Route | Service = IP/DNS interno estável para pods; Route = entrada HTTP(S) externa via Ingress, apontando para um Service | 06, 07 |
| Role × ClusterRole | Role vale em um namespace; ClusterRole define permissões que podem ser concedidas em um namespace (RoleBinding) ou no cluster todo (ClusterRoleBinding) | 15 |
| requests × limits | request = reserva usada pelo agendador; limit = teto aplicado em execução (CPU é estrangulada, memória acima do limite causa OOMKill) | 11 |
| `rollout undo` × `rollout restart` | undo volta ao template de uma revisão anterior; restart recria os pods com o template atual | 05 |
| ConfigMap × Secret | mesma mecânica de injeção; Secret tem RBAC e tratamento de exibição próprios (base64 não é criptografia) | 08 |
| readiness × liveness × startup | readiness tira o pod do Service; liveness reinicia o contêiner; startup adia as outras durante a inicialização | 11 |
