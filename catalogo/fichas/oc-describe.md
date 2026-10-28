# Ficha: `oc describe`

> **Impacto:** LEITURA · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [ORI-006](../../trilhas/00-orientacao/exercicios/ORI-006.md), [ORI-008](../../trilhas/00-orientacao/exercicios/ORI-008.md), [CON-013](../../trilhas/02-consultas/exercicios/CON-013.md)

## Quando usar

Diagnóstico: estado legível, condições e **eventos** de um objeto ou de um conjunto selecionado por rótulo.

## Forma canônica

```bash
oc describe pod <pod> -n ac02-consultas
```

## Sintaxe

```text
oc describe TIPO [NOME | -l SELETOR] [-n NS]
```

## Exemplos no HomeLab

```bash
oc describe deployment obs-web -n ac02-consultas
oc describe svc obs-web -n ac02-consultas
oc describe pods -l app=obs-web -n ac02-consultas | sed -n '/Events:/,$p'
oc describe node ocp-sno.ocp.example.lab | sed -n '/Allocated resources:/,/Events:/p'
```

## Flags principais

| Flag | Efeito |
|---|---|
| `-l` | descreve todos os selecionados |
| `--show-events=false` | omite eventos |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc get -o yaml` | objeto exato, reaproveitável; sem eventos |
| `oc get events` | todos os eventos do namespace |

## Antes e depois

Use depois de qualquer sintoma (`Pending`, `CrashLoopBackOff`, `ImagePullBackOff`) — a seção Events costuma dar a causa.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
Name:         obs-web-xxxxxxxxxx-aaaaa
Namespace:    ac02-consultas
Status:       Running
...
Events:
  Type    Reason     Age   From               Message
  Normal  Scheduled  5m    default-scheduler  Successfully assigned ...
```

## Erros comuns

- Eventos ausentes: expiraram (TTL) ou o objeto é antigo.

## Ajuda e documentação

```bash
oc describe --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura; nada a desfazer.
