# Ficha: `oc wait`

> **Impacto:** LEITURA · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [CON-003](../../trilhas/02-consultas/exercicios/CON-003.md), [CON-014](../../trilhas/02-consultas/exercicios/CON-014.md)

## Quando usar

Bloquear um script até uma condição ser verdadeira (ou o objeto sumir), com timeout — em vez de repetir `oc get`.

## Forma canônica

```bash
oc wait --for=condition=Available deployment/obs-web -n ac02-consultas --timeout=180s
```

## Sintaxe

```text
oc wait (TIPO/NOME | TIPO -l SELETOR) --for=condition=C | --for=jsonpath='{...}'=V | --for=delete [--timeout=T]
```

## Exemplos no HomeLab

```bash
oc wait --for=condition=Available deployment/obs-web -n ac02-consultas --timeout=180s
oc wait --for=condition=Ready pod -l app=obs-web -n ac02-consultas --timeout=120s
oc wait --for=jsonpath='{.status.readyReplicas}'=2 deployment/obs-web -n ac02-consultas --timeout=120s
oc wait --for=delete configmap/ac02-temp -n ac02-consultas --timeout=60s
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--for=condition=` | condição em `status.conditions` |
| `--for=jsonpath=` | campo com valor |
| `--for=delete` | espera a exclusão |
| `--timeout` | padrão 30 s; sempre defina |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc rollout status` | acompanha o rollout do novo ReplicaSet |
| `oc get -w` | mostra mudanças, não termina sozinho |

## Antes e depois

Depois de `apply`/`scale`/`restart`; o código de saída diz se a condição foi atingida.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
deployment.apps/obs-web condition met
```

## Erros comuns

- `timed out waiting for the condition`: código ≠ 0; investigue com eventos e `rollout status`.

## Ajuda e documentação

```bash
oc wait --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura; nada a desfazer.
