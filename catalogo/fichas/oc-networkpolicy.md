# Ficha: NetworkPolicy, testes de conectividade e TLS

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL (políticas no projeto) · LEITURA (rede do cluster) · **Perfil mínimo:** developer; admin só para leitura da rede do cluster · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [NET-002](../../trilhas/16-rede/exercicios/NET-002.md), [NET-003](../../trilhas/16-rede/exercicios/NET-003.md), [NET-005](../../trilhas/16-rede/exercicios/NET-005.md), [NET-007](../../trilhas/16-rede/exercicios/NET-007.md), [NET-008](../../trilhas/16-rede/exercicios/NET-008.md), [NET-010](../../trilhas/16-rede/exercicios/NET-010.md), [NET-014](../../trilhas/16-rede/exercicios/NET-014.md)

## Quando usar

Para isolar projetos e aplicações (entrada e saída) e diagnosticar quem fala com quem, inclusive por TLS.

## Forma canônica

```bash
oc get networkpolicy -n ac16-rede
```

## Sintaxe

```text
oc get|describe networkpolicy [NOME] -n NS
oc apply -f politica.yaml -n NS   (sempre com -n)
oc delete networkpolicy -l academy.openshift.dev/managed-by=academia -n NS
oc exec POD -n NS -- timeout 3 bash -c '</dev/tcp/DESTINO/PORTA'
openssl s_client -connect IP:443 -servername HOST </dev/null | openssl x509 -noout -subject -issuer -enddate
```

## Exemplos no HomeLab

```bash
oc apply -f manifests/networkpolicies/00-negar-entrada.yaml -n ac16-rede
oc apply -f manifests/networkpolicies/10-permitir-mesmo-projeto.yaml -n ac16-rede
oc apply -f manifests/networkpolicies/30-permitir-router.yaml -n ac16-rede
oc apply -f manifests/networkpolicies/40-negar-saida.yaml -f manifests/networkpolicies/50-permitir-dns.yaml -n ac16-rede
oc exec ac16-local -n ac16-rede -- timeout 3 bash -c '</dev/tcp/web-azul/8080' && echo ok
oc annotate svc web-verde service.beta.openshift.io/serving-cert-secret-name=web-verde-tls -n ac16-rede
```

## Flags principais

| Campo | Efeito |
|---|---|
| `podSelector` | pods aos quais a política se aplica (`{}` = todos do projeto) |
| `policyTypes` | `Ingress`, `Egress` ou ambos |
| `from`/`to` | origens/destinos; **cada item é um OR**, seletores no mesmo item são AND |
| `namespaceSelector` | outros projetos (`kubernetes.io/metadata.name`, grupo de ingress) |
| `ports` | porta do **contêiner** (número, nome, intervalo com `endPort`) |
| `ipBlock` | faixas de IP (destinos externos) |

## Comparação com comandos próximos

| Falha | Significa |
|---|---|
| timeout | descartado (política) ou sem rota |
| connection refused | chegou, ninguém escuta na porta |
| nome não resolve | DNS (ou saída para o DNS bloqueada) |
| erro de certificado | TLS: SNI, CA ou nome |

## Antes e depois

Antes de aplicar: a matriz de conectividade (NET-002). Depois: a mesma matriz deve mudar só onde você pretendia.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME                  POD-SELECTOR   AGE
ac16-negar-entrada    <none>         5m
ac16-mesmo-projeto    <none>         5m
ac16-router           app=loja       2m
```

## Erros comuns

- Route com 503 depois do isolamento: router não liberado (TS-049).
- Nada resolve depois da política de saída: DNS bloqueado, ou liberado na 53 em vez da 5353 (TS-050).
- Política "só para X" deixou entrar mais gente: OR na lista `from` (TS-051).
- Porta do Service liberada e acesso bloqueado: a política usa a porta do contêiner (NET-006).

## Ajuda e documentação

```bash
oc explain networkpolicy.spec
oc explain networkpolicy.spec.ingress.from
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc delete networkpolicy <nome> -n <ns>` (sem políticas, o projeto volta ao padrão aberto).
