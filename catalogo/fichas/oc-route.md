# Ficha: `oc expose svc` e `oc create route`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [RTE-001](../../trilhas/07-rotas/exercicios/RTE-001.md), [RTE-003](../../trilhas/07-rotas/exercicios/RTE-003.md), [RTE-006](../../trilhas/07-rotas/exercicios/RTE-006.md), [RTE-008](../../trilhas/07-rotas/exercicios/RTE-008.md), [RTE-010](../../trilhas/07-rotas/exercicios/RTE-010.md), [RTE-014](../../trilhas/07-rotas/exercicios/RTE-014.md)

## Quando usar

Para publicar um Service por HTTP/HTTPS fora do cluster, através do router do Ingress Controller.

## Forma canônica

```bash
oc expose svc/web-azul -n ac07-rotas
```

## Sintaxe

```text
oc expose svc/NOME [--name=R] [--hostname=H] [--path=/p]
oc create route edge|passthrough|reencrypt NOME --service=S [--port=P] [--hostname=H]
       [--cert --key --ca-cert] [--dest-ca-cert] [--insecure-policy=Redirect|Allow|None]
oc set route-backends ROTA svc1=peso svc2=peso | --equal | --adjust svc=+N
```

## Exemplos no HomeLab

```bash
oc expose svc/web-azul -n ac07-rotas
oc expose svc/web-azul --name=loja --hostname=loja-ac07.apps.ocp.example.lab -n ac07-rotas
oc create route edge seguro --service=web-azul --hostname=seguro-ac07.apps.ocp.example.lab --insecure-policy=Redirect -n ac07-rotas
oc create route passthrough direto --service=web-azul-tls --hostname=direto-ac07.apps.ocp.example.lab -n ac07-rotas
oc set route-backends ab web-azul=80 web-verde=20 -n ac07-rotas
curl -sS -H 'Host: loja-ac07.apps.ocp.example.lab' http://192.168.10.200/
```

## Flags principais

| Flag / anotação | Efeito |
|---|---|
| `--hostname` | host da Route (precisa resolver para o router no cliente) |
| `--path` | Route por caminho |
| `--insecure-policy` | o que fazer com HTTP em Route TLS (`Redirect`, `Allow`, `None`) |
| `--cert/--key/--ca-cert` | certificado próprio (edge/reencrypt) |
| `haproxy.router.openshift.io/rewrite-target` | reescreve o caminho |
| `haproxy.router.openshift.io/disable_cookies` | sem cookie de afinidade |
| `haproxy.router.openshift.io/timeout` | tempo máximo de resposta |

## Comparação com comandos próximos

| Terminação | TLS termina em | Router vê HTTP? |
|---|---|---|
| (nenhuma) | — | sim |
| `edge` | router | sim |
| `passthrough` | pod | não (só SNI) |
| `reencrypt` | router, e novo TLS até o pod | sim |

## Antes e depois

Depois de criar: `status.ingress[0].conditions` (Admitted) e um `curl` pela `ocp-admin`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME       HOST/PORT                                  PATH   SERVICES   PORT   TERMINATION     WILDCARD
web-azul   web-azul-ac07-rotas.apps.ocp.example.lab          web-azul   8080                   None
seguro     seguro-ac07.apps.ocp.example.lab                  web-azul   8080   edge/Redirect   None
```

## Erros comuns

- 503 "Application is not available": sem endpoints, Service errado ou host desconhecido (TS-022).
- `HostAlreadyClaimed`: outra Route mais antiga tem o host (TS-023).
- `Could not resolve host`: hostname fora de `*.apps` ou falta de entrada no `hosts` do Windows (TS-024).
- `SSL certificate problem`: CA do Ingress não confiável no cliente (use `--cacert` ou `-k` no HomeLab).

## Ajuda e documentação

```bash
oc expose --help
oc create route edge --help
oc set route-backends --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc delete route <nome>`; remova as linhas do `hosts` do Windows.
