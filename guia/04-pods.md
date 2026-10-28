# Guia direto 04 — Pods e contêineres

> Perfil: `developer`. Projeto de treino: `ac04-pods`. Imagem usada: `registry.access.redhat.com/ubi9/httpd-24:latest`.
> Exercícios completos: [trilhas/04-pods](../trilhas/04-pods/README.md).

## 1. Criar o projeto e ver o YAML de um Pod — Leitura

```bash
oc new-project ac04-pods
oc run ac04-web --image=registry.access.redhat.com/ubi9/httpd-24:latest --dry-run=client -o yaml
oc explain pod.spec.containers
```

| Comando | O que faz |
|---|---|
| `oc run ... --dry-run=client -o yaml` | mostra o Pod que **seria** criado, sem criar |
| `oc explain pod.spec.containers` | documentação dos campos de contêiner |

## 2. Criar um Pod e acompanhar — Altera

```bash
oc run ac04-web --image=registry.access.redhat.com/ubi9/httpd-24:latest \
  --labels=app=ac04-web --port=8080 -n ac04-pods
oc get pods -n ac04-pods -w
oc wait --for=condition=Ready pod/ac04-web -n ac04-pods --timeout=120s
oc get pod ac04-web -n ac04-pods -o wide
oc describe pod ac04-web -n ac04-pods | sed -n '/Events:/,$p'
```

| Comando / opção | O que faz |
|---|---|
| `--labels` | rótulos do Pod |
| `--port` | documenta a porta do contêiner |
| `-w` | acompanha `Pending → ContainerCreating → Running` (Ctrl+C para sair) |
| `oc wait --for=condition=Ready` | espera o Pod ficar pronto |
| `-o wide` | IP do Pod e nó |
| `describe ... Events` | o que aconteceu: agendado, imagem baixada, contêiner iniciado |

## 3. Pods que terminam — Altera

```bash
oc run ac04-ok   --image=registry.access.redhat.com/ubi9/httpd-24:latest --restart=Never -n ac04-pods --command -- sh -c 'echo ok; exit 0'
oc run ac04-erro --image=registry.access.redhat.com/ubi9/httpd-24:latest --restart=Never -n ac04-pods --command -- sh -c 'echo falhou; exit 1'
oc get pods -n ac04-pods
oc get pod ac04-erro -n ac04-pods -o jsonpath='{.status.containerStatuses[0].state.terminated.exitCode}{"\n"}'
oc delete pod ac04-ok ac04-erro -n ac04-pods
```

| `--restart=` | Saída 0 | Saída ≠ 0 |
|---|---|---|
| `Never` | `Completed` | `Error` |
| `OnFailure` | `Completed` | reinicia → `CrashLoopBackOff` |
| `Always` (padrão) | reinicia → `CrashLoopBackOff` | reinicia → `CrashLoopBackOff` |

`--command -- ...` define o comando do contêiner (substitui o da imagem).

## 4. Logs — Leitura

```bash
oc logs ac04-web -n ac04-pods
oc logs ac04-web -n ac04-pods --tail=5
oc logs ac04-web -n ac04-pods --since=5m --timestamps
oc logs -f ac04-web -n ac04-pods
oc logs -l app=ac04-web -n ac04-pods
oc logs <pod> -n ac04-pods --previous
```

| Opção | O que faz |
|---|---|
| `--tail=5` | últimas 5 linhas |
| `--since=5m` | só os últimos 5 minutos |
| `--timestamps` | horário em cada linha |
| `-f` | segue em tempo real |
| `-l` | logs dos pods com o rótulo |
| `--previous` | logs da execução **anterior** (depois de um reinício) |

Só aparece o que o contêiner escreve na saída padrão (stdout/stderr).

## 5. Pod com vários contêineres — Altera

```bash
oc apply -f manifests/apps-exemplo/pod-dois-conteineres.yaml -n ac04-pods
oc get pod ac04-duplo -n ac04-pods -o jsonpath='{.spec.initContainers[*].name} | {.spec.containers[*].name}{"\n"}'
oc logs ac04-duplo -n ac04-pods -c preparo
oc logs ac04-duplo -n ac04-pods -c relogio --tail=3
oc logs ac04-duplo -n ac04-pods --all-containers=true --prefix=true --tail=3
```

| Opção | O que faz |
|---|---|
| `-c <nome>` | escolhe o contêiner (vale para `logs`, `exec`, `rsh`, `cp`) |
| `--all-containers=true` | logs de todos |
| `--prefix=true` | indica de qual contêiner veio cada linha |

Init containers rodam antes e precisam terminar com sucesso; os demais contêineres dividem o mesmo IP (`localhost`).

## 6. Rodar comandos dentro do contêiner — Leitura

```bash
oc exec ac04-web -n ac04-pods -- id
oc exec ac04-web -n ac04-pods -- hostname
oc exec ac04-web -n ac04-pods -- env
oc exec ac04-web -n ac04-pods -- cat /etc/os-release
oc exec ac04-web -n ac04-pods -- sh -c 'echo $HOME; ls -la /tmp'
oc exec ac04-duplo -c relogio -n ac04-pods -- date
```

| Trecho | O que faz |
|---|---|
| `--` | separa as opções do `oc` do comando que roda no contêiner |
| `sh -c '...'` | necessário para usar variáveis (`$HOME`), `;` e `\|` |
| `-c` | contêiner específico |

Só existe o que a imagem tem (às vezes não há `ps` nem `curl`). O que você criar some quando o contêiner é recriado.

## 7. Shell interativo — Leitura

```bash
oc rsh ac04-web -n ac04-pods
oc exec -it ac04-web -n ac04-pods -- /bin/bash
oc rsh -c relogio ac04-duplo -n ac04-pods
```

| Comando | O que faz |
|---|---|
| `oc rsh <pod>` | abre um shell no contêiner (saia com `exit`) |
| `oc exec -it ... -- /bin/bash` | mesmo efeito; `-i` = entrada, `-t` = terminal |

## 8. Copiar arquivos — Altera (arquivos em `/tmp`)

```bash
echo "ola" > /tmp/nota.txt
oc cp /tmp/nota.txt ac04-web:/tmp/nota.txt -n ac04-pods
oc exec ac04-web -n ac04-pods -- cat /tmp/nota.txt
oc cp ac04-web:/etc/httpd/conf/httpd.conf /tmp/httpd.conf -n ac04-pods
oc cp /tmp/nota.txt ac04-duplo:/tmp/nota.txt -c relogio -n ac04-pods
```

| Forma | Sentido |
|---|---|
| `oc cp <local> <pod>:<caminho>` | da `ocp-admin` para o pod |
| `oc cp <pod>:<caminho> <local>` | do pod para a `ocp-admin` |

Usa `tar` dentro do contêiner. Grave em `/tmp`: diretórios do sistema não são graváveis.

## 9. Acessar o pod pela ocp-admin — Leitura

```bash
oc port-forward pod/ac04-web 18080:8080 -n ac04-pods &
sleep 3
curl -sS -o /dev/null -w 'HTTP %{http_code}\n' http://127.0.0.1:18080/
kill %1
```

| Trecho | O que faz |
|---|---|
| `18080:8080` | porta 18080 da `ocp-admin` → porta 8080 do pod |
| `&` / `kill %1` | roda em segundo plano / encerra o túnel |
| HTTP 403 | normal: é a página padrão do httpd, o túnel funcionou |

Também funciona com `svc/<nome>`. Confira que nenhum túnel ficou aberto: `pgrep -af 'oc port-forward'`.

## 10. attach × logs × exec — Leitura

| Comando | Conecta a | Envia entrada? |
|---|---|---|
| `oc logs -f <pod>` | saída já registrada | não |
| `oc attach -i <pod>` | processo **principal** | sim, se o contêiner tiver `stdin: true` |
| `oc exec <pod> -- cmd` | um processo **novo** | sim, ao processo novo |

## 11. Comando e variáveis — Altera

```bash
oc run ac04-env --image=registry.access.redhat.com/ubi9/httpd-24:latest --restart=Never -n ac04-pods \
  --env=SAUDACAO=ola --command -- sh -c 'echo "$SAUDACAO de $(hostname)"'
oc logs ac04-env -n ac04-pods
oc set env pod/ac04-web --list -n ac04-pods
oc delete pod ac04-env -n ac04-pods
```

| Pod define | O que roda |
|---|---|
| nada | `ENTRYPOINT` + `CMD` da imagem |
| só `args` | `ENTRYPOINT` + `args` |
| `command` (`--command --`) | só `command` |

`$(VAR)` é expandido pelo Kubernetes; `$VAR` só dentro de um shell (`sh -c`).

## 12. Requests, limits e QoS — Leitura

```bash
oc get pod ac04-web -n ac04-pods -o jsonpath='{.status.qosClass}{"\n"}'
oc get pod ac04-web -n ac04-pods -o jsonpath='{.spec.containers[0].resources}{"\n"}'
oc describe limitrange -n ac04-pods
```

| QoS | Regra |
|---|---|
| `Guaranteed` | requests = limits de CPU e memória em todos os contêineres |
| `Burstable` | tem algum request ou limit, mas não é Guaranteed |
| `BestEffort` | nenhum request nem limit (é o primeiro a ser removido se faltar memória no nó) |

Recursos de um pod existente não se editam: recrie o pod (ou use um Deployment, Trilha 05).

## 13. Investigar com uma cópia — Altera (pod temporário)

```bash
oc apply -f manifests/apps-exemplo/cenario-crashloop.yaml -n ac04-pods
oc logs ac04-crash -n ac04-pods --previous
oc debug pod/ac04-crash -n ac04-pods
oc debug pod/ac04-crash -n ac04-pods -- sh -c 'id; env | sort | head'
oc delete pod ac04-crash -n ac04-pods
```

| Comando | O que faz |
|---|---|
| `oc debug pod/<nome>` | cria uma **cópia** do pod com um shell, sem rótulos (não recebe tráfego); é apagada ao sair |
| `oc debug ... -- <cmd>` | roda um comando na cópia e sai |

**Nunca** use `oc debug node/...` no SNO.

## 14. Do pod ao contêiner real — Leitura

```bash
oc get pod ac04-web -n ac04-pods -o jsonpath='{.spec.containers[0].image}{"\n"}'
oc get pod ac04-web -n ac04-pods -o jsonpath='{.status.containerStatuses[0].imageID}{"\n"}'
oc get pod ac04-web -n ac04-pods -o jsonpath='{.status.containerStatuses[0].containerID}{"\n"}'
oc get pod ac04-web -n ac04-pods -o jsonpath='{.spec.nodeName}{"\n"}'
```

| Campo | Significado |
|---|---|
| `image` | o que foi pedido (a tag pode mudar) |
| `imageID` | a imagem exata em execução (digest `sha256:...`) |
| `containerID` | ID do contêiner no CRI-O |

## 15. Os três erros mais comuns de pod — Leitura

| STATUS | Primeiro comando | Causa típica |
|---|---|---|
| `CrashLoopBackOff` | `oc logs <pod> --previous` | o processo termina com erro |
| `Pending` | `oc describe pod <pod>` (Events: `FailedScheduling`) | nenhum nó atende ao pedido |
| `OOMKilled` (código 137) | `oc get pod <pod> -o jsonpath='{.status.containerStatuses[0].lastState}'` | passou do `limits.memory` |
| `ImagePullBackOff` | `oc describe pod <pod>` (Events) | imagem ou tag inexistente, registry inacessível |

Pratique cada um nos cenários [TS-013](../cenarios/troubleshooting/TS-013.md), [TS-014](../cenarios/troubleshooting/TS-014.md) e [TS-015](../cenarios/troubleshooting/TS-015.md).

## 16. Encerrar a trilha — Altera

```bash
pkill -f 'oc port-forward' || true
oc delete project ac04-pods
oc get project ac04-pods      # até NotFound
rm -f /tmp/nota.txt /tmp/httpd.conf
```
