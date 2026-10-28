# Ficha: `oc port-forward`

> **Impacto:** LEITURA (túnel local temporário) · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [POD-009](../../trilhas/04-pods/exercicios/POD-009.md)

## Quando usar

Para acessar, pela `ocp-admin`, uma porta de um pod ou Service sem criar Route — diagnóstico rápido.

## Forma canônica

```bash
oc port-forward pod/ac04-web 18080:8080 -n ac04-pods
```

## Sintaxe

```text
oc port-forward (pod/NOME | svc/NOME | deploy/NOME) [PORTA_LOCAL:]PORTA_REMOTA [-n NS] [--address=127.0.0.1]
```

## Exemplos no HomeLab

```bash
oc port-forward pod/ac04-web 18080:8080 -n ac04-pods &
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18080/
kill %1
oc port-forward svc/ac04-web :8080 -n ac04-pods      # porta local automática
```

## Flags principais

| Item | Efeito |
|---|---|
| `18080:8080` | porta local : porta do pod |
| `:8080` | escolhe uma porta local livre |
| `svc/` ou `deploy/` | escolhe **um** pod do alvo |
| `--address` | interface local (padrão `127.0.0.1`) |

## Comparação com comandos próximos

| Forma de acesso | Quando |
|---|---|
| `port-forward` | diagnóstico pessoal, temporário |
| Service | acesso dentro do cluster |
| Route | acesso externo permanente (Trilha 07) |

## Antes e depois

Depois: encerre o túnel (`kill`, Ctrl+C) e confira com `pgrep -af 'oc port-forward'`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
Forwarding from 127.0.0.1:18080 -> 8080
Handling connection for 18080
```

## Erros comuns

- `address already in use`: outro túnel aberto na mesma porta.

## Ajuda e documentação

```bash
oc port-forward --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Encerre o processo do túnel.
