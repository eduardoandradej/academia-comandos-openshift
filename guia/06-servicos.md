# Guia direto 06 — Services e DNS

> Perfil: `developer`. Projeto de treino: `ac06-servicos`.
> Exercícios completos: [trilhas/06-servicos](../trilhas/06-servicos/README.md).

## 1. Preparar backends e um cliente — Altera

```bash
oc new-project ac06-servicos
oc apply -f manifests/apps-exemplo/servicos-azul-verde.yaml -n ac06-servicos
oc run ac06-cliente --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac06-servicos --command -- sleep infinity
oc wait --for=condition=Available deploy/web-azul deploy/web-verde -n ac06-servicos --timeout=180s
```

O manifesto (em `manifests/`, após o `git clone`) cria dois backends httpd: `web-azul` responde `azul`, `web-verde`
responde `verde`. Os dois têm o rótulo `app=loja`; a cor fica no rótulo `cor`.

Função para testar HTTP **de dentro** do cluster (a `ocp-admin` não alcança IPs internos):

```bash
http() { oc exec ac06-cliente -n ac06-servicos -- bash -c "exec 3<>/dev/tcp/$1/${2:-8080} && printf 'GET / HTTP/1.0\r\n\r\n' >&3 && cat <&3" | tail -1; }
```

| Trecho | O que faz |
|---|---|
| `oc exec ac06-cliente -- bash -c` | roda o teste dentro do pod cliente |
| `/dev/tcp/<host>/<porta>` | abre uma conexão TCP pelo bash (dispensa `curl`) |
| `printf 'GET / ...'` | envia uma requisição HTTP mínima |
| `tail -1` | mostra a última linha da resposta (a cor) |

## 2. Criar um Service — Altera

```bash
oc expose deployment/web-azul --port=8080 -n ac06-servicos
oc get svc web-azul -n ac06-servicos
oc describe svc web-azul -n ac06-servicos
http web-azul
```

| Comando | O que faz |
|---|---|
| `oc expose deployment/<nome> --port=8080` | cria um Service com o seletor do Deployment |
| `oc describe svc` | mostra seletor, IP, portas e endpoints |
| `http web-azul` | testa pelo nome (deve responder `azul`) |

Pods ganham IP novo a cada recriação; o Service mantém nome e IP fixos.

## 3. Portas: port e targetPort — Altera

```bash
oc create service clusterip loja-80 --tcp=80:8080 -n ac06-servicos
oc set selector svc/loja-80 app=loja,cor=azul -n ac06-servicos
http loja-80 80
```

| Campo | Significado |
|---|---|
| `port` (80) | porta que o cliente usa no Service |
| `targetPort` (8080) | porta do contêiner (pode ser um **nome**, como `http`) |

## 4. Quem está por trás do Service — Leitura

```bash
oc get endpointslices -n ac06-servicos -l kubernetes.io/service-name=web-azul
oc get endpointslices -n ac06-servicos -l kubernetes.io/service-name=web-azul \
  -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]} {.targetRef.name} ready={.conditions.ready}{"\n"}{end}'
```

| Campo | Significado |
|---|---|
| `addresses` | IP do pod |
| `targetRef.name` | nome do pod |
| `ready` | só pods prontos recebem tráfego |

(`oc get endpoints` ainda funciona, mas está obsoleto.)

## 5. DNS interno — Leitura

```bash
oc exec ac06-cliente -n ac06-servicos -- cat /etc/resolv.conf
oc exec ac06-cliente -n ac06-servicos -- getent hosts web-azul
oc exec ac06-cliente -n ac06-servicos -- getent hosts web-azul.ac06-servicos
oc exec ac06-cliente -n ac06-servicos -- getent hosts web-azul.ac06-servicos.svc.cluster.local
oc exec ac06-cliente -n ac06-servicos -- getent hosts kubernetes.default.svc.cluster.local
```

| Nome | Funciona de onde |
|---|---|
| `web-azul` | só do mesmo namespace |
| `web-azul.ac06-servicos` | de qualquer namespace |
| `web-azul.ac06-servicos.svc.cluster.local` | de qualquer namespace (nome completo) |

A linha `search` do `resolv.conf` é o que completa os nomes curtos.

## 6. Trocar azul por verde — Altera

```bash
oc create service clusterip loja --tcp=8080:8080 -n ac06-servicos
oc set selector svc/loja app=loja,cor=azul -n ac06-servicos;  http loja    # azul
oc set selector svc/loja app=loja,cor=verde -n ac06-servicos; http loja    # verde
oc set selector svc/loja app=loja,cor=azul -n ac06-servicos;  http loja    # azul
```

O Service escolhe os pods **pelo seletor**. Trocar o seletor troca o tráfego na hora, sem recriar nada (liberação azul/verde).

## 7. Balanceamento entre vários pods — Leitura

```bash
oc set selector svc/loja app=loja -n ac06-servicos
for i in $(seq 20); do http loja; done | sort | uniq -c
```

Com os dois backends no seletor, as respostas se dividem entre `azul` e `verde`. A escolha é por **conexão** e não é
exatamente alternada.

## 8. Service headless — Altera

```bash
oc create service clusterip loja-headless --clusterip=None --tcp=8080:8080 -n ac06-servicos
oc set selector svc/loja-headless app=loja -n ac06-servicos
oc exec ac06-cliente -n ac06-servicos -- getent ahosts loja-headless | awk '{print $1}' | sort -u
```

| Service | O DNS devolve |
|---|---|
| comum | o IP do Service (ClusterIP) |
| headless (`--clusterip=None`) | os IPs dos pods |

## 9. Duas portas no mesmo Service — Altera

```bash
oc create service clusterip loja-dupla --tcp=8080:8080 --tcp=8443:8443 -n ac06-servicos
oc set selector svc/loja-dupla app=loja,cor=azul -n ac06-servicos
oc get svc loja-dupla -n ac06-servicos -o jsonpath='{.spec.ports}{"\n"}'
```

Com mais de uma porta, cada uma precisa de um nome.

## 10. Apelido DNS (ExternalName) — Altera

```bash
oc create service externalname api-cluster --external-name=kubernetes.default.svc.cluster.local -n ac06-servicos
oc exec ac06-cliente -n ac06-servicos -- getent hosts api-cluster
```

`ExternalName` não tem IP nem pods: o DNS responde um apelido (CNAME) para outro nome.

## 11. Afinidade de sessão — Altera

```bash
oc patch svc loja -n ac06-servicos --type=merge -p '{"spec":{"sessionAffinity":"ClientIP"}}'
for i in $(seq 20); do http loja; done | sort | uniq -c       # uma cor só
oc patch svc loja -n ac06-servicos --type=merge -p '{"spec":{"sessionAffinity":"None","sessionAffinityConfig":null}}'
```

`ClientIP` faz o mesmo cliente cair sempre no mesmo pod.

## 12. Tipos de Service no HomeLab — Leitura

| Tipo | No HomeLab |
|---|---|
| `ClusterIP` | usado em tudo |
| `NodePort` | bloqueado pela quota da Academia |
| `LoadBalancer` | não existe no SNO (nenhum provedor de IP externo) |
| Route | o caminho para acesso externo HTTP/HTTPS (Trilha 07) |

## 13. Roteiro de diagnóstico de Service — Leitura

| # | Pergunta | Comando |
|---|---|---|
| 1 | O Service existe? | `oc get svc <svc> -n <ns>` |
| 2 | O seletor encontra pods? | `oc get pods -n <ns> -l <seletor do svc>` |
| 3 | Os pods estão prontos? | coluna `READY` de `oc get pods` |
| 4 | Há endpoints prontos? | `oc get endpointslices -l kubernetes.io/service-name=<svc>` |
| 5 | A porta confere? | `targetPort` do Service × `containerPort` do pod |
| 6 | O nome resolve? | `oc exec <cliente> -- getent hosts <svc>.<ns>` |
| 7 | A conexão responde? | `http <svc>.<ns>` |

| Sintoma | Causa típica | Cenário |
|---|---|---|
| `Endpoints: <none>` | seletor sem pods ou pods não prontos | [TS-021](../cenarios/troubleshooting/TS-021.md) |
| endpoints prontos, conexão recusada | `targetPort` errado | [TS-019](../cenarios/troubleshooting/TS-019.md) |
| nome não resolve em outro projeto | uso do nome curto | [TS-020](../cenarios/troubleshooting/TS-020.md) |

## 14. Encerrar a trilha — Altera

```bash
oc delete project ac06-servicos
oc get project ac06-servicos      # até NotFound
```
