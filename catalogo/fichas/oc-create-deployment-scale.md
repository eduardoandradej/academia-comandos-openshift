# Ficha: `oc create deployment`, `oc new-app` e `oc scale`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [DEP-001](../../trilhas/05-deployments/exercicios/DEP-001.md), [DEP-002](../../trilhas/05-deployments/exercicios/DEP-002.md), [DEP-009](../../trilhas/05-deployments/exercicios/DEP-009.md)

## Quando usar

Para criar aplicações gerenciadas (que se recuperam sozinhas) e ajustar o número de réplicas.

## Forma canônica

```bash
oc create deployment ac05-web --image=registry.access.redhat.com/ubi9/httpd-24:latest --replicas=2 -n ac05-deploy
```

## Sintaxe

```text
oc create deployment NOME --image=IMG [--replicas=N] [--port=P] [--dry-run=client -o yaml] [-- COMANDO]
oc new-app --image=IMG --name=NOME [-l k=v] [--dry-run -o yaml]
oc scale (deployment/NOME | rs/NOME) --replicas=N [--current-replicas=M]
```

## Exemplos no HomeLab

```bash
oc create deployment ac05-web --image=registry.access.redhat.com/ubi9/httpd-24:latest --replicas=2 --port=8080 -n ac05-deploy
oc new-app --image=registry.access.redhat.com/ubi9/httpd-24:latest --name=ac05-app -l academy.openshift.dev/managed-by=academia -n ac05-deploy
oc scale deployment/ac05-web --replicas=1 -n ac05-deploy
oc scale deployment/ac05-web --replicas=2 --current-replicas=1 -n ac05-deploy
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--replicas` | número de pods (teto da Academia: 2) |
| `--port` | porta do contêiner |
| `-l` (new-app) | rótulos em todos os objetos gerados |
| `--current-replicas` | só escala se o valor atual for esse |

## Comparação com comandos próximos

| Comando | Cria |
|---|---|
| `oc run` | um Pod avulso (não se recupera) |
| `oc create deployment` | um Deployment |
| `oc new-app --image` | Deployment + Service (+ ImageStream) |

## Antes e depois

Depois: `oc rollout status deployment/<nome>`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
deployment.apps/ac05-web created
deployment.apps/ac05-web scaled
```

## Erros comuns

- `AlreadyExists`: use `--dry-run=client -o yaml | oc apply -f -` para repetir sem erro.
- `Expected replicas to be N, was M`: a pré-condição `--current-replicas` não conferiu.
- Réplicas faltando sem pods Pending: quota (veja TS-018).

## Ajuda e documentação

```bash
oc create deployment --help
oc new-app --help
oc scale --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc delete deployment <nome>` (apaga ReplicaSets e pods).
