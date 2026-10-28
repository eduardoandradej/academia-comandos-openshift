# Guia direto 02 — Leitura e inspeção

> Perfil: `developer`. Projeto de treino: `ac02-consultas`.
> Exercícios completos: [trilhas/02-consultas](../trilhas/02-consultas/README.md).

## 0. Preparar algo para ler — Altera (só o projeto de treino)

```bash
oc new-project ac02-consultas
oc apply -f manifests/apps-exemplo/observacao-httpd.yaml -n ac02-consultas
oc wait --for=condition=Available deployment/obs-web -n ac02-consultas --timeout=180s
```

O arquivo (em `manifests/`, disponível após o `git clone`) cria 2 pods httpd pequenos, um Service e um ConfigMap,
todos com rótulos `app=obs-web`, `tier=web` e `academy.openshift.dev/managed-by=academia`.

## 1. Que tipos de objeto existem? — Leitura

```bash
oc api-resources
oc api-resources --namespaced=false
oc api-resources --api-group=apps
oc api-resources | grep -i deploy
```

| Comando | O que faz |
|---|---|
| `oc api-resources` | todos os tipos: nome, apelido, grupo, se vive dentro de um namespace e o Kind |
| `--namespaced=false` | só os tipos do cluster inteiro (nodes, projects...) |
| `--api-group=apps` | só os tipos de um grupo |

## 2. Documentação de qualquer campo — Leitura

```bash
oc explain deployment
oc explain deployment.spec.replicas
oc explain pod.spec.containers.resources
oc explain pod.spec --recursive | less
```

| Comando | O que faz |
|---|---|
| `oc explain <tipo>.<campo>` | explica o campo: tipo, descrição e valores aceitos |
| `--recursive` | árvore de todos os campos |

## 3. `oc get` — o básico — Leitura

```bash
oc get pods -n ac02-consultas
oc get pods -n ac02-consultas -o wide
oc get deploy,rs,pods,svc -n ac02-consultas
oc get pods -n ac02-consultas -o name
oc get pods -n ac02-consultas --show-labels
oc get pods -n ac02-consultas --no-headers | wc -l
oc get all -n ac02-consultas
```

| Opção | O que faz |
|---|---|
| `-o wide` | colunas extras: IP do pod, nó |
| `deploy,rs,pods,svc` | vários tipos de uma vez |
| `-o name` | só `tipo/nome` (bom para usar em outros comandos) |
| `--show-labels` | mostra os rótulos |
| `--no-headers` | sem cabeçalho (bom para contar) |
| `oc get all` | atalho para os tipos principais (não inclui ConfigMaps e Secrets) |

## 4. Filtrar por rótulo — Leitura

```bash
oc get pods -n ac02-consultas -l app=obs-web
oc get pods -n ac02-consultas -l 'app=obs-web,tier=web'
oc get pods -n ac02-consultas -l 'tier in (web,api)'
oc get pods -n ac02-consultas -l '!tier'
oc get pods -n ac02-consultas -L app,tier
```

| Seletor | Seleciona |
|---|---|
| `-l app=obs-web` | rótulo igual |
| `-l 'a=1,b=2'` | os dois (E) |
| `-l 'tier in (web,api)'` | valor em uma lista |
| `-l '!tier'` | quem **não** tem o rótulo |
| `-L app,tier` | mostra os rótulos como colunas |

## 5. Filtrar por campo — Leitura

```bash
oc get pods -n ac02-consultas --field-selector=status.phase=Running
oc get pods -n ac02-consultas --field-selector=status.phase!=Running
oc get events -n ac02-consultas --field-selector type=Warning
```

| Opção | O que faz |
|---|---|
| `--field-selector=status.phase=Running` | só pods rodando |
| `type=Warning` (eventos) | só alertas |

Só alguns campos aceitam esse filtro (em pods: `status.phase`, `spec.nodeName`, `metadata.name`...).

## 6. O objeto completo: YAML e JSON — Leitura

```bash
oc get deployment obs-web -n ac02-consultas -o yaml
oc get deployment obs-web -n ac02-consultas -o json | jq '.status'
oc get pods -n ac02-consultas -o json | jq '.items[0].metadata.ownerReferences'
```

| Parte | Significado |
|---|---|
| `metadata` | nome, rótulos, anotações, dono (`ownerReferences`) |
| `spec` | o que você **pediu** |
| `status` | o que **está acontecendo** (escrito pelo cluster) |

## 7. Extrair campos com JSONPath — Leitura

```bash
oc get deployment obs-web -n ac02-consultas -o jsonpath='{.spec.replicas}{"\n"}'
oc get pods -n ac02-consultas -o jsonpath='{.items[*].metadata.name}{"\n"}'
oc get pods -n ac02-consultas -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.podIP}{"\n"}{end}'
oc get pods -n ac02-consultas -o jsonpath='{range .items[*]}{.metadata.name}{" ready="}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'
oc get deployment obs-web -n ac02-consultas -o jsonpath='{.metadata.labels.academy\.openshift\.dev/trilha}{"\n"}'
```

| Trecho | O que faz |
|---|---|
| `{.campo}` | um campo |
| `{.items[*].campo}` | o campo de todos os itens |
| `{range .items[*]}...{end}` | um laço: uma linha por item |
| `{"\n"}`, `{"\t"}` | quebra de linha, tabulação |
| `[?(@.type=="Ready")]` | filtra uma lista |
| `\.` | escapa pontos dentro de nomes de rótulo |

> JSONPath não dá erro se o caminho estiver errado: só não imprime nada. Confira maiúsculas e minúsculas.

## 8. Tabela sob medida — Leitura

```bash
oc get pods -n ac02-consultas -o custom-columns=NOME:.metadata.name,FASE:.status.phase,IP:.status.podIP
oc get deploy -n ac02-consultas -o custom-columns=NOME:.metadata.name,DESEJADO:.spec.replicas,PRONTO:.status.readyReplicas
```

| Formato | Regra |
|---|---|
| `TITULO:caminho,TITULO2:caminho2` | uma coluna por par; o caminho é igual ao do JSONPath, sem chaves |

## 9. go-template — Leitura

```bash
oc get pods -n ac02-consultas -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'
oc get pods -n ac02-consultas -o go-template='{{len .items}}{{"\n"}}'
oc get pods -n ac02-consultas -o go-template='{{range .items}}{{if ne .status.phase "Running"}}! {{end}}{{.metadata.name}}{{"\n"}}{{end}}'
```

| Trecho | O que faz |
|---|---|
| `{{range .items}}...{{end}}` | laço |
| `{{len .items}}` | conta |
| `{{if ne .status.phase "Running"}}` | condição |

## 10. jq — Leitura

```bash
oc get pods -n ac02-consultas -o json | jq '.items | length'
oc get pods -n ac02-consultas -o json | jq -r '.items[].metadata.name'
oc get pods -n ac02-consultas -o json | jq -r '.items[] | select(.status.phase=="Running") | .metadata.name'
oc get pods -n ac02-consultas -o json | jq '[.items[] | {nome: .metadata.name, ip: .status.podIP}]'
```

| Filtro | O que faz |
|---|---|
| `.items[]` | percorre a lista |
| `select(...)` | mantém só o que atende |
| `{nome: ...}` | monta um objeto novo |
| `-r` | texto sem aspas |

Qual usar? Um campo simples → JSONPath. Tabela → custom-columns. Contas, somas, lógica → jq.

## 11. Eventos — Leitura

```bash
oc get events -n ac02-consultas --sort-by=.metadata.creationTimestamp
oc get events -n ac02-consultas --field-selector type=Warning
oc get events -n ac02-consultas -w
```

| Opção | O que faz |
|---|---|
| `--sort-by=.metadata.creationTimestamp` | em ordem cronológica |
| `-w` | acompanha em tempo real (Ctrl+C para sair) |

Eventos expiram em cerca de uma hora.

## 12. `describe` × `get -o yaml` — Leitura

```bash
oc describe deployment obs-web -n ac02-consultas
oc describe svc obs-web -n ac02-consultas
oc describe pods -l app=obs-web -n ac02-consultas | sed -n '/Events:/,$p'
```

| Use | Quando |
|---|---|
| `oc describe` | "o que está acontecendo?" — mostra os **eventos** e dados agregados (ex.: endpoints do Service) |
| `oc get -o yaml` | "qual é o valor exato?" — o objeto como está guardado |

## 13. Acompanhar e esperar — Altera (reinicia os pods de treino)

```bash
oc get pods -n ac02-consultas -l app=obs-web -w
oc rollout restart deployment/obs-web -n ac02-consultas
oc wait --for=condition=Available deployment/obs-web -n ac02-consultas --timeout=180s
oc wait --for=jsonpath='{.status.readyReplicas}'=2 deployment/obs-web -n ac02-consultas --timeout=120s
```

| Comando | O que faz |
|---|---|
| `-w` | mostra cada mudança |
| `oc wait --for=condition=...` | espera uma condição (ex.: `Available`) |
| `--for=jsonpath=...=valor` | espera um campo ter certo valor |
| `--timeout=` | tempo máximo (padrão de 30 s; sempre informe) |

## 14. Falar direto com a API — Leitura

```bash
oc get --raw /apis | jq -r '.groups[].name'
oc get --raw /apis/apps/v1/namespaces/ac02-consultas/deployments | jq -r '.items[].metadata.name'
oc get --raw "/api/v1/namespaces/ac02-consultas/pods?labelSelector=app%3Dobs-web" | jq -r '.items[].metadata.name'
```

| Caminho | Contém |
|---|---|
| `/api/v1/...` | tipos básicos (pods, services, configmaps) |
| `/apis/<grupo>/<versão>/...` | demais tipos (deployments, routes...) |

## 15. Encerrar a trilha — Altera

```bash
oc delete project ac02-consultas
oc get project ac02-consultas      # até NotFound
```
