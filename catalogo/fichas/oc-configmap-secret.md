# Ficha: `oc create configmap` e `oc create secret`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [CFG-001](../../trilhas/08-config/exercicios/CFG-001.md), [CFG-005](../../trilhas/08-config/exercicios/CFG-005.md), [CFG-007](../../trilhas/08-config/exercicios/CFG-007.md), [CFG-008](../../trilhas/08-config/exercicios/CFG-008.md), [CFG-012](../../trilhas/08-config/exercicios/CFG-012.md), [CFG-013](../../trilhas/08-config/exercicios/CFG-013.md)

## Quando usar

Para separar configuração (ConfigMap) e dados sensíveis (Secret) da imagem e injetá-los nos pods.

## Forma canônica

```bash
oc create configmap app-cfg --from-literal=MODO=treino -n ac08-config
```

## Sintaxe

```text
oc create configmap NOME [--from-literal=K=V] [--from-file=[chave=]arquivo|dir] [--from-env-file=arquivo]
oc create secret generic NOME [mesmas origens] [--type=T]
oc create secret tls NOME --cert=crt --key=key
oc create secret docker-registry NOME --docker-server=S --docker-username=U --docker-password=P
oc set data configmap|secret/NOME K=V | K- | --from-file=...
oc extract configmap|secret/NOME --to=dir|- [--keys=K] [--confirm]
```

## Exemplos no HomeLab

```bash
oc create configmap ac08-literal --from-literal=MODO=treino --from-literal=NIVEL_LOG=debug -n ac08-config
oc create configmap ac08-arquivo --from-file=principal.conf=/tmp/ac08/app.conf -n ac08-config
oc create configmap ac08-env --from-env-file=/tmp/ac08/app.env -n ac08-config
read -rs S; oc create secret generic ac08-api --from-literal=token="$S" -n ac08-config; unset S
oc create secret tls ac08-tls --cert=/tmp/ac08/tls.crt --key=/tmp/ac08/tls.key -n ac08-config
oc describe secret ac08-api -n ac08-config
oc create configmap ac08-env --from-env-file=/tmp/ac08/app.env --dry-run=client -o yaml | oc apply -n ac08-config -f -
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--from-literal=K=V` | uma chave por par |
| `--from-file=[chave=]arq` | conteúdo inteiro do arquivo (chave = nome do arquivo, se omitida) |
| `--from-env-file` | uma chave por linha `K=V` (não combina com as outras origens) |
| `--type` | tipo do Secret (`Opaque` por padrão) |
| `--dry-run=client -o yaml` | gera sem criar (base do padrão idempotente com `apply`) |

## Comparação com comandos próximos

| | ConfigMap | Secret |
|---|---|---|
| Conteúdo | configuração não sensível | dados sensíveis |
| Armazenamento em `data` | texto | base64 (**não** é criptografia) |
| Papel `view` lê | sim | **não** |
| `describe` mostra | valores | só tamanho em bytes |

## Antes e depois

Leia só chaves e tamanhos: `oc describe secret` ou `jq '.data | keys'`. Evite `-o yaml` de Secrets em telas compartilhadas.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
Name:         ac08-api
Type:  Opaque
Data
====
token:  14 bytes
```

## Erros comuns

- `AlreadyExists`: use `--dry-run=client -o yaml | oc apply -f -`.
- `from-env-file cannot be combined`: gere em partes e mescle (CFG-001).
- `CreateContainerConfigError` no pod: ConfigMap/Secret/chave ausente (TS-025).
- Secret com 1 byte a mais: `\n` do `echo` (TS-027).

## Ajuda e documentação

```bash
oc create configmap --help
oc create secret --help
oc set data --help
oc extract --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc delete configmap|secret <nome>`; reinicie os Deployments que os consomem.
