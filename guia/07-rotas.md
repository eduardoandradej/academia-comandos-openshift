# Guia direto 07 — Routes e Ingress

> Perfil: `developer`. Projeto de treino: `ac07-rotas`. Testes com `curl` na `ocp-admin`.
> Exercícios completos: [trilhas/07-rotas](../trilhas/07-rotas/README.md).

## 0. Antes de começar — Leitura

```bash
getent ahostsv4 teste.apps.ocp.example.lab     # deve responder 192.168.10.200
```

Se não responder, a `ocp-admin` não está usando o DNS do HomeLab (`192.168.10.25`). Enquanto isso, use o truque da
seção 3 (`curl -H 'Host: ...'`).

## 1. Preparar backends — Altera

```bash
oc new-project ac07-rotas
oc apply -f manifests/apps-exemplo/servicos-azul-verde.yaml -n ac07-rotas
oc wait --for=condition=Available deploy/web-azul deploy/web-verde -n ac07-rotas --timeout=180s
oc expose deployment/web-azul --port=8080 -n ac07-rotas
oc expose deployment/web-verde --port=8080 -n ac07-rotas
```

Dois backends: `web-azul` responde `azul`, `web-verde` responde `verde`.

## 2. Primeira Route — Altera

```bash
oc expose svc/web-azul -n ac07-rotas
oc get route web-azul -n ac07-rotas
curl -sS http://web-azul-ac07-rotas.apps.ocp.example.lab/
```

| Comando | O que faz |
|---|---|
| `oc expose svc/<nome>` | cria uma Route HTTP para o Service |
| host gerado | `<route>-<projeto>.apps.ocp.example.lab` |
| `curl` | testa pela `ocp-admin` (deve responder `azul`) |

Caminho: cliente → DNS `*.apps` → `192.168.10.200` (router) → Route → Service → pod.

## 3. Testar sem DNS — Leitura

```bash
curl -sS -H 'Host: web-azul-ac07-rotas.apps.ocp.example.lab' http://192.168.10.200/
curl -sS --resolve web-azul-ac07-rotas.apps.ocp.example.lab:80:192.168.10.200 http://web-azul-ac07-rotas.apps.ocp.example.lab/
```

O router escolhe a Route pelo nome pedido (cabeçalho `Host` em HTTP, SNI em HTTPS). Um nome desconhecido recebe 503.

## 4. Hostname próprio e o Windows — Altera

```bash
oc expose svc/web-azul --name=loja --hostname=loja-ac07.apps.ocp.example.lab -n ac07-rotas
curl -sS http://loja-ac07.apps.ocp.example.lab/
```

No Windows (PowerShell como Administrador), **uma linha por hostname** (o `hosts` não aceita curinga):

```powershell
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "192.168.10.200 loja-ac07.apps.ocp.example.lab"
ipconfig /flushdns
```

Use sempre nomes terminados em `.apps.ocp.example.lab`: fora disso, nada resolve.

## 5. Rotas por caminho — Altera

```bash
oc expose svc/web-azul  --name=cores-azul  --hostname=cores-ac07.apps.ocp.example.lab --path=/azul  -n ac07-rotas
oc expose svc/web-verde --name=cores-verde --hostname=cores-ac07.apps.ocp.example.lab --path=/verde -n ac07-rotas
oc annotate route cores-azul cores-verde haproxy.router.openshift.io/rewrite-target=/ -n ac07-rotas
curl -sS http://cores-ac07.apps.ocp.example.lab/azul
curl -sS http://cores-ac07.apps.ocp.example.lab/verde
```

| Item | O que faz |
|---|---|
| `--path=/azul` | a Route só atende esse caminho |
| `rewrite-target=/` | entrega `/` ao backend em vez de `/azul` (senão, 404) |

## 6. A Route foi aceita? — Leitura

```bash
oc get route web-azul -n ac07-rotas -o jsonpath='{.status.ingress[0].conditions[0].type}={.status.ingress[0].conditions[0].status} {.status.ingress[0].conditions[0].reason}{"\n"}'
oc describe route web-azul -n ac07-rotas
```

`Admitted=True` = publicada. `HostAlreadyClaimed` = outra Route, mais antiga, já usa esse host.

## 7. HTTPS com o certificado padrão (edge) — Altera

```bash
oc create route edge seguro --service=web-azul --hostname=seguro-ac07.apps.ocp.example.lab --insecure-policy=Redirect -n ac07-rotas
curl -sS -o /dev/null -w '%{http_code}\n' http://seguro-ac07.apps.ocp.example.lab/    # 302 (redireciona)
curl -sSk https://seguro-ac07.apps.ocp.example.lab/                                   # azul
openssl s_client -connect 192.168.10.200:443 -servername seguro-ac07.apps.ocp.example.lab </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer
```

| Item | O que faz |
|---|---|
| `edge` | o TLS termina no router; do router ao pod é HTTP |
| `--insecure-policy=Redirect` | HTTP vira HTTPS |
| `-k` | aceita o certificado sem validar (a CA do cluster não é conhecida pela `ocp-admin`) |

## 8. HTTPS com certificado próprio — Altera (chave de treino em `/tmp`)

```bash
mkdir -p /tmp/ac07 && cd /tmp/ac07
openssl req -x509 -newkey rsa:2048 -nodes -days 30 -keyout proprio.key -out proprio.crt \
  -subj "/CN=proprio-ac07.apps.ocp.example.lab" -addext "subjectAltName=DNS:proprio-ac07.apps.ocp.example.lab"
oc create route edge proprio --service=web-azul --hostname=proprio-ac07.apps.ocp.example.lab \
  --cert=proprio.crt --key=proprio.key -n ac07-rotas
curl -sS --cacert proprio.crt https://proprio-ac07.apps.ocp.example.lab/      # azul, sem -k
cd - >/dev/null
```

O certificado precisa ter o hostname no `subjectAltName`. Nunca coloque `.key` ou `.crt` no repositório.

## 9. Passthrough: TLS até o pod — Altera

```bash
oc expose deployment/web-azul --name=web-azul-tls --port=8443 -n ac07-rotas
oc create route passthrough direto --service=web-azul-tls --hostname=direto-ac07.apps.ocp.example.lab -n ac07-rotas
curl -sSk https://direto-ac07.apps.ocp.example.lab/
```

O router não decifra nada: repassa o TLS ao httpd (porta 8443), que usa o próprio certificado.

| Terminação | Onde o TLS termina | O certificado visto é do |
|---|---|---|
| `edge` | no router | router |
| `passthrough` | no pod | pod |
| `reencrypt` | no router, que abre outro TLS até o pod | router |

## 10. Dividir o tráfego por peso — Altera

```bash
oc expose svc/web-azul --name=ab --hostname=ab-ac07.apps.ocp.example.lab -n ac07-rotas
oc annotate route ab haproxy.router.openshift.io/disable_cookies=true -n ac07-rotas
oc set route-backends ab web-azul=80 web-verde=20 -n ac07-rotas
for i in $(seq 50); do curl -sS http://ab-ac07.apps.ocp.example.lab/; done | sort | uniq -c
oc set route-backends ab --equal -n ac07-rotas
```

| Comando | O que faz |
|---|---|
| `oc set route-backends <rota> a=80 b=20` | 80% do tráfego para `a`, 20% para `b` |
| `disable_cookies=true` | sem o cookie que prende o cliente a um backend |
| `--equal` | divide igualmente |

## 11. Anotações úteis — Altera

```bash
oc annotate route web-azul haproxy.router.openshift.io/timeout=5s -n ac07-rotas
oc annotate route web-azul haproxy.router.openshift.io/balance=roundrobin -n ac07-rotas
oc annotate route web-azul haproxy.router.openshift.io/timeout- haproxy.router.openshift.io/balance- -n ac07-rotas
```

| Anotação (`haproxy.router.openshift.io/...`) | Efeito |
|---|---|
| `timeout` | tempo máximo de resposta |
| `balance` | algoritmo de balanceamento |
| `disable_cookies` | sem afinidade por cookie |
| `rewrite-target` | reescreve o caminho |

## 12. Ingress vira Route — Altera

```bash
oc create ingress loja-ing --rule="ing-ac07.apps.ocp.example.lab/*=web-azul:8080" -n ac07-rotas
oc get routes -n ac07-rotas
curl -sS http://ing-ac07.apps.ocp.example.lab/
oc delete ingress loja-ing -n ac07-rotas
```

O OpenShift cria uma Route a partir do Ingress. Edite o Ingress, não a Route gerada.

## 13. Visão do admin — Leitura (perfil admin)

```bash
oc get co ingress
oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.status.domain} {.status.endpointPublishingStrategy.type}{"\n"}'
oc get pods -n openshift-ingress -o wide
```

Apenas leitura: alterar o Ingress Controller pode derrubar a Console e o login.

## 14. Diagnóstico de Route — Leitura

| # | Pergunta | Comando |
|---|---|---|
| 1 | O nome resolve no cliente? | `getent ahostsv4 <host>` |
| 2 | O router responde? | `timeout 3 bash -c '</dev/tcp/192.168.10.200/80'` |
| 3 | A Route foi aceita? | `status.ingress[0].conditions` |
| 4 | O Service existe? | `oc get svc <spec.to.name>` |
| 5 | Há endpoints prontos? | `oc get endpointslices -l kubernetes.io/service-name=<svc>` |
| 6 | A resposta é a esperada? | `curl -sS -o /dev/null -w '%{http_code}' http://<host>/` |

| Sintoma | Causa típica | Cenário |
|---|---|---|
| 503 "Application is not available" | Service sem endpoints | [TS-022](../cenarios/troubleshooting/TS-022.md) |
| Route nova sem tráfego | `HostAlreadyClaimed` | [TS-023](../cenarios/troubleshooting/TS-023.md) |
| `Could not resolve host` | hostname fora de `*.apps` | [TS-024](../cenarios/troubleshooting/TS-024.md) |
| `SSL certificate problem` | CA não confiável no cliente | seção 7 |

## 15. Encerrar a trilha — Altera

```bash
oc delete project ac07-rotas
oc get project ac07-rotas      # até NotFound
rm -rf /tmp/ac07
```

No Windows, remova do `hosts` as linhas com `ac07`.
