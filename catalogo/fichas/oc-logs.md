# Ficha: `oc logs`

> **Impacto:** LEITURA · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [POD-004](../../trilhas/04-pods/exercicios/POD-004.md), [POD-005](../../trilhas/04-pods/exercicios/POD-005.md), [POD-010](../../trilhas/04-pods/exercicios/POD-010.md)

## Quando usar

Ler a saída padrão e de erro dos contêineres: atual, contínua, de um período, da instância anterior, de um contêiner específico.

## Forma canônica

```bash
oc logs <pod> -n <ns> --tail=20
```

## Sintaxe

```text
oc logs (POD | TIPO/NOME | -l SELETOR) [-c CONTÊINER | --all-containers] [-f] [--previous] [--tail=N] [--since=DUR] [--timestamps] [--prefix]
```

## Exemplos no HomeLab

```bash
oc logs ac04-web -n ac04-pods --tail=5 --timestamps
oc logs -f ac04-log -n ac04-pods
oc logs ac04-crash -n ac04-pods --previous
oc logs ac04-duplo -n ac04-pods -c relogio --since=1m
oc logs ac04-duplo -n ac04-pods --all-containers=true --prefix=true
oc logs deployment/obs-web -n ac02-consultas --tail=3
```

## Flags principais

| Flag | Efeito |
|---|---|
| `-f` | segue em tempo real |
| `--previous` / `-p` | instância anterior (após reinício) |
| `--tail=N`, `--since=5m` | recorte |
| `--timestamps` | horário em cada linha |
| `-c` / `--all-containers` | contêiner específico / todos |
| `--prefix` | indica de qual pod/contêiner veio cada linha |
| `-l` | vários pods por rótulo |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc attach` | conecta ao processo principal (pode enviar entrada) |
| `oc get events` | eventos do Kubernetes, não a saída da aplicação |

## Antes e depois

Depois de qualquer falha de contêiner: `--previous` primeiro.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
2026-10-28T10:00:01.123Z linha 41
2026-10-28T10:00:03.125Z linha 42
```

## Erros comuns

- Saída vazia: a aplicação grava em arquivo, não em stdout; ou o contêiner acabou de reiniciar (use `--previous`).
- `previous terminated container ... not found`: o contêiner nunca reiniciou.

## Ajuda e documentação

```bash
oc logs --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura; nada a desfazer.
