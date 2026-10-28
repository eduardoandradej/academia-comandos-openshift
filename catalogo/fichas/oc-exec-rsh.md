# Ficha: `oc exec`, `oc rsh`, `oc cp` e `oc debug`

> **Impacto:** LEITURA (comandos de leitura) · MUTAÇÃO LOCAL (arquivos/pods temporários) · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [POD-006](../../trilhas/04-pods/exercicios/POD-006.md), [POD-007](../../trilhas/04-pods/exercicios/POD-007.md), [POD-008](../../trilhas/04-pods/exercicios/POD-008.md), [POD-013](../../trilhas/04-pods/exercicios/POD-013.md)

## Quando usar

Para entrar em um contêiner em execução, rodar um comando pontual, copiar arquivos ou investigar uma cópia de um pod.

## Forma canônica

```bash
oc exec <pod> -n <ns> -- id
```

## Sintaxe

```text
oc exec POD [-c C] [-i] [-t] -- COMANDO
oc rsh [-c C] POD [COMANDO]
oc cp ORIGEM DESTINO [-c C]   (lado remoto: POD:/caminho)
oc debug (POD | deploy/NOME) [--image=IMG] [-- COMANDO]
```

## Exemplos no HomeLab

```bash
oc exec ac04-web -n ac04-pods -- id
oc exec ac04-web -n ac04-pods -- sh -c 'echo $HOME'
oc exec -it ac04-web -n ac04-pods -- /bin/bash
oc rsh -c relogio ac04-duplo -n ac04-pods
oc cp /tmp/nota.txt ac04-web:/tmp/nota.txt -n ac04-pods
oc debug pod/ac04-crash -n ac04-pods -- sh -c 'id; hostname'
```

## Flags principais

| Item | Efeito |
|---|---|
| `--` | separa as opções do `oc` do comando remoto |
| `-i` / `-t` | entrada aberta / terminal (para shells) |
| `-c` | contêiner específico |
| `oc cp` | usa `tar` dentro do contêiner |
| `oc debug` | cria uma cópia sem rótulos, com shell, apagada ao sair |

## Comparação com comandos próximos

| Comando | Novo processo? | Afeta o original? |
|---|---|---|
| `oc exec` / `oc rsh` | sim, no mesmo contêiner | só o que você fizer lá dentro (não persiste após recriação) |
| `oc attach` | não (processo principal) | sim, a entrada chega ao processo |
| `oc debug` | sim, em um pod novo | não |

## Antes e depois

Antes: `oc get pod <pod> -o jsonpath='{.spec.containers[*].name}'` (qual contêiner?). Depois: saia com `exit`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
uid=1000690000(1000690000) gid=0(root) groups=0(root),1000690000
```

## Erros comuns

- `executable file not found in $PATH` / código 127: a imagem não tem o utilitário.
- `Unable to use a TTY`: `-t` sem terminal local (scripts).
- `Permission denied` no `oc cp`: diretório não gravável pelo UID do contêiner; use `/tmp`.
- **`oc debug node/...` é proibido nesta Academia** (pod privilegiado no nó único).

## Ajuda e documentação

```bash
oc exec --help
oc rsh --help
oc cp --help
oc debug --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Apague o que criou (`rm` no contêiner, pods `-debug` restantes).
