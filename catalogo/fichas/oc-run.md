# Ficha: `oc run`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL (cria um Pod) · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [POD-001](../../trilhas/04-pods/exercicios/POD-001.md), [POD-002](../../trilhas/04-pods/exercicios/POD-002.md), [POD-003](../../trilhas/04-pods/exercicios/POD-003.md), [POD-011](../../trilhas/04-pods/exercicios/POD-011.md)

## Quando usar

Para criar um Pod avulso rapidamente (treino, diagnóstico) ou gerar o YAML de um Pod com `--dry-run=client -o yaml`.

## Forma canônica

```bash
oc run ac04-web --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac04-pods
```

## Sintaxe

```text
oc run NOME --image=IMAGEM [--labels=k=v,...] [--env=K=V] [--port=N] [--restart=Always|OnFailure|Never]
       [-i] [-t] [--rm] [--attach=false] [--overrides=JSON] [--dry-run=client -o yaml] [--command] -- [COMANDO/ARGS]
```

## Exemplos no HomeLab

```bash
oc run ac04-web --image=registry.access.redhat.com/ubi9/httpd-24:latest --labels=app=ac04-web,academy.openshift.dev/managed-by=academia --port=8080 -n ac04-pods
oc run ac04-n0 --image=registry.access.redhat.com/ubi9/httpd-24:latest --restart=Never --command -n ac04-pods -- /bin/sh -c 'echo ok'
oc run x --image=registry.access.redhat.com/ubi9/httpd-24:latest --dry-run=client -o yaml
oc run ac04-tmp --image=registry.access.redhat.com/ubi9/httpd-24:latest -it --rm --restart=Never -n ac04-pods -- bash
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--image` | imagem (obrigatória) |
| `--labels` | rótulos do Pod |
| `--env` | variável de ambiente (repetível) |
| `--restart` | `Always` (padrão), `OnFailure`, `Never` |
| `--command -- ...` | o que vem depois de `--` vira `command` (sem a flag, vira `args`) |
| `-i` / `-t` / `--rm` | entrada aberta / terminal / apaga ao sair |
| `--overrides` | JSON mesclado ao objeto gerado (ex.: `resources`) |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc create deployment` | cria um Deployment (pods recriados automaticamente) |
| `oc debug` | cria uma cópia de pod existente para investigar |
| `oc apply -f` | cria a partir de YAML completo |

## Antes e depois

Antes: `oc auth can-i create pods -n <ns>`. Depois: `oc wait --for=condition=Ready pod/<nome>`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
pod/ac04-web created
```

## Erros comuns

- `unknown flag: --limits` / `--requests`: removidas; use YAML ou `--overrides`.
- `AlreadyExists`: apague o Pod anterior (`oc delete pod <nome> --wait=true`).

## Ajuda e documentação

```bash
oc run --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc delete pod <nome> -n <ns>`.
