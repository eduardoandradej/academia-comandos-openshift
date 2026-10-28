# Ficha: `oc expose`, `oc create service` e `oc set selector`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [SVC-001](../../trilhas/06-servicos/exercicios/SVC-001.md), [SVC-002](../../trilhas/06-servicos/exercicios/SVC-002.md), [SVC-006](../../trilhas/06-servicos/exercicios/SVC-006.md), [SVC-008](../../trilhas/06-servicos/exercicios/SVC-008.md), [SVC-011](../../trilhas/06-servicos/exercicios/SVC-011.md), [SVC-014](../../trilhas/06-servicos/exercicios/SVC-014.md)

## Quando usar

Para dar um nome e um IP estáveis a um conjunto de pods (Service) e controlar quais pods recebem o tráfego.

## Forma canônica

```bash
oc expose deployment/web-azul --port=8080 -n ac06-servicos
```

## Sintaxe

```text
oc expose (deployment|pod|svc)/NOME --port=P [--target-port=T] [--name=N]
oc create service (clusterip|nodeport|loadbalancer|externalname) NOME --tcp=PORTA:ALVO [--clusterip=None] [--external-name=DNS]
oc set selector svc/NOME chave=valor[,chave=valor]
```

## Exemplos no HomeLab

```bash
oc expose deployment/web-azul --port=8080 -n ac06-servicos
oc create service clusterip loja --tcp=8080:8080 -n ac06-servicos
oc set selector svc/loja app=loja,cor=verde -n ac06-servicos
oc create service clusterip loja-headless --clusterip=None --tcp=8080:8080 -n ac06-servicos
oc create service externalname api-cluster --external-name=kubernetes.default.svc.cluster.local -n ac06-servicos
oc get endpointslices -n ac06-servicos -l kubernetes.io/service-name=loja
```

## Flags principais

| Item | Efeito |
|---|---|
| `port` / `targetPort` | porta do Service / porta (ou nome) no contêiner |
| `--tcp=80:8080` | `port:targetPort` no `create service` |
| `--clusterip=None` | Service headless (DNS devolve IPs dos pods) |
| `oc set selector` | troca os pods de destino (azul/verde) |
| `sessionAffinity: ClientIP` | mesmo cliente → mesmo pod |

## Comparação com comandos próximos

| Tipo | Alcance |
|---|---|
| `ClusterIP` | dentro do cluster (padrão) |
| headless | dentro do cluster, sem IP virtual |
| `ExternalName` | só um CNAME no DNS |
| `NodePort` / `LoadBalancer` | fora do cluster — bloqueados pela quota da Academia; LB inexistente no SNO |
| Route | HTTP/HTTPS externo pelo Ingress (Trilha 07) |

## Antes e depois

Depois de criar: EndpointSlices com endpoints `ready` e um teste a partir de um pod cliente (`/dev/tcp` ou `curl`).

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
web-azul   ClusterIP   172.30.x.x     <none>        8080/TCP   1m
```

## Erros comuns

- `Endpoints: <none>`: seletor sem pods ou pods não prontos (TS-021).
- Endpoints prontos e conexão recusada: `targetPort` errado (TS-019).
- Nome não resolve em outro projeto: use `<svc>.<ns>` (TS-020).
- `exceeded quota ... services.nodeports`: quota da Academia.

## Ajuda e documentação

```bash
oc expose --help
oc create service --help
oc set selector --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc delete svc <nome>`; volte o seletor anterior com `oc set selector`.
