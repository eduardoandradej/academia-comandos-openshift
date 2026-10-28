# Guia direto 16 — Rede e isolamento

> Perfil: `developer`. Projetos: `ac16-rede` (loja) e `ac16-vizinho` (clientes). Políticas prontas em
> [`manifests/networkpolicies/`](../manifests/networkpolicies/README.md). Exercícios completos: [trilhas/16-rede](../trilhas/16-rede/README.md).

## 1. Montar o laboratório — Altera

```bash
oc new-project ac16-rede
oc apply -f manifests/apps-exemplo/servicos-azul-verde.yaml -n ac16-rede
oc expose deployment/web-azul --port=8080 -n ac16-rede
oc run ac16-local --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac16-rede -l app=ac16-cliente --command -- sleep 86400
oc new-project ac16-vizinho
oc run ac16-cliente --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac16-vizinho -l app=ac16-cliente --command -- sleep 86400
oc run ac16-intruso --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac16-vizinho -l app=intruso --command -- sleep 86400
oc project ac16-rede
```

Função de teste (sem `curl` nos pods):

```bash
t() { oc exec "$1" -n "$2" -- timeout 3 bash -c "exec 3<>/dev/tcp/$3/${4:-8080} && printf 'GET / HTTP/1.0\r\n\r\n' >&3 && tail -1 <&3" 2>/dev/null || echo FALHOU; }
t ac16-local   ac16-rede    web-azul                     # azul
t ac16-cliente ac16-vizinho web-azul.ac16-rede.svc       # azul: sem políticas, tudo é aberto
```

## 2. Negar toda a entrada — Altera

```bash
oc apply -f manifests/networkpolicies/00-negar-entrada.yaml -n ac16-rede
t ac16-local ac16-rede web-azul                          # FALHOU (até o próprio projeto)
```

```yaml
spec:
  podSelector: {}          # todos os pods do projeto
  policyTypes: [Ingress]   # sem regras "ingress": nada entra
```

## 3. Liberar o próprio projeto — Altera

```bash
oc apply -f manifests/networkpolicies/10-permitir-mesmo-projeto.yaml -n ac16-rede
t ac16-local   ac16-rede    web-azul                     # azul
t ac16-cliente ac16-vizinho web-azul.ac16-rede.svc       # FALHOU
```

Políticas **somam**: não há ordem nem prioridade.

## 4. Liberar um cliente de outro projeto — Altera

```bash
oc apply -f manifests/networkpolicies/20-permitir-cliente-vizinho.yaml -n ac16-rede
t ac16-cliente ac16-vizinho web-azul.ac16-rede.svc       # azul
t ac16-intruso ac16-vizinho web-azul.ac16-rede.svc       # FALHOU
```

| Em `from` | Significa |
|---|---|
| `- namespaceSelector: ...` + `podSelector: ...` (mesmo item) | projeto **E** pod |
| `- namespaceSelector: ...` e `- podSelector: ...` (itens separados) | projeto **OU** pod do próprio projeto ([TS-051](../cenarios/troubleshooting/TS-051.md)) |

## 5. Portas — Leitura

`ports` usa a porta **do contêiner** (`targetPort`), por número (`8080`), nome (`http`) ou intervalo (`endPort`).

## 6. Routes depois do isolamento — Altera

```bash
oc expose svc/web-azul -n ac16-rede
curl -sS -m 5 "http://$(oc get route web-azul -n ac16-rede -o jsonpath='{.spec.host}')/"   # 503/timeout
oc apply -f manifests/networkpolicies/30-permitir-router.yaml -n ac16-rede                 # libera o router
```

O router está em `openshift-ingress` (rótulo `policy-group.network.openshift.io/ingress: ""`) — [TS-049](../cenarios/troubleshooting/TS-049.md).

## 7. Negar a saída sem perder o DNS — Altera

```bash
oc apply -f manifests/networkpolicies/40-negar-saida.yaml -n ac16-rede
oc exec ac16-local -n ac16-rede -- timeout 5 getent hosts web-azul || echo "DNS bloqueado"
oc apply -f manifests/networkpolicies/50-permitir-dns.yaml -n ac16-rede                    # porta 5353 do openshift-dns
oc apply -f manifests/networkpolicies/60-permitir-saida-loja.yaml -n ac16-rede             # cliente só fala com a loja
```

## 8. Quais políticas valem para um pod — Leitura

```bash
oc get networkpolicy -n ac16-rede -o custom-columns=NOME:.metadata.name,SELETOR:.spec.podSelector,TIPOS:.spec.policyTypes
oc get pods -n ac16-rede --show-labels
oc describe networkpolicy -n ac16-rede
```

## 9. Camadas do admin — Leitura (admin)

| Camada | Ordem |
|---|---|
| AdminNetworkPolicy | 1ª (pode Allow, Deny ou Pass) |
| NetworkPolicy (do projeto) | 2ª |
| BaselineAdminNetworkPolicy | última (padrão) |
| EgressFirewall | saída para fora do cluster por IP ou nome DNS |

## 10. TLS visto de fora — Leitura

```bash
H=console-openshift-console.apps.ocp.example.lab
openssl s_client -connect 192.168.10.200:443 -servername "$H" </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -enddate -ext subjectAltName
```

Sem `-servername`, o router devolve o certificado padrão, não o da sua Route.

## 11. Certificado de serviço — Altera

```bash
oc annotate service web-verde service.beta.openshift.io/serving-cert-secret-name=web-verde-tls -n ac16-rede
oc get secret web-verde-tls -n ac16-rede -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -subject -issuer
oc create configmap ac16-ca -n ac16-rede && oc annotate configmap ac16-ca service.beta.openshift.io/inject-cabundle=true -n ac16-rede
```

## 12. Diagnóstico — Leitura

| Sintoma | Causa provável |
|---|---|
| timeout | política descartou (entrada no destino ou saída na origem) |
| connection refused | ninguém escuta na porta (`targetPort`) |
| nome não resolve | DNS ou saída para o DNS bloqueada ([TS-050](../cenarios/troubleshooting/TS-050.md)) |
| Route 503 com pods prontos | router bloqueado ([TS-049](../cenarios/troubleshooting/TS-049.md)) |
| entrou quem não devia | OR na lista `from` ([TS-051](../cenarios/troubleshooting/TS-051.md)) |

## 13. Encerrar a trilha — Altera

```bash
oc delete project ac16-rede ac16-vizinho
```
