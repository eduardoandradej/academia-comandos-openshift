# Ficha: `oc auth can-i`

> **Impacto:** LEITURA · **Perfil mínimo:** qualquer autenticado (`--as` exige permissão de personificação) · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [ORI-003](../../trilhas/00-orientacao/exercicios/ORI-003.md), [ORI-010](../../trilhas/00-orientacao/exercicios/ORI-010.md), [ORI-013](../../trilhas/00-orientacao/exercicios/ORI-013.md), [ORI-014](../../trilhas/00-orientacao/exercicios/ORI-014.md)

## Quando usar

Perguntar à API se uma ação seria permitida — **sem executá-la**. Base do "pensar antes de mutar".

## Forma canônica

```bash
oc auth can-i create configmaps -n ac00-orientacao
```

## Sintaxe

```text
oc auth can-i VERBO RECURSO[/NOME] [-n NS | --all-namespaces] [--as=USUÁRIO]
oc auth can-i --list [-n NS]
```

## Exemplos no HomeLab

```bash
oc auth can-i create projectrequests
oc auth can-i delete pods -n ac00-orientacao
oc auth can-i list nodes
oc auth can-i --list -n ac00-orientacao | head
oc auth can-i get nodes --as=developer          # no perfil admin
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--list` | tudo o que você pode fazer |
| `--as` | pergunta por outro usuário (personificação) |
| `--all-namespaces` | escopo de cluster |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc adm policy who-can VERBO RECURSO` | quem pode (visão inversa; admin) |
| `--dry-run=server` | testa a requisição inteira (inclui validação e quota) |

## Antes e depois

Antes de qualquer mutação AMARELA.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
yes
```

## Erros comuns

- `no` não significa que o comando é seguro: significa que **você** não pode. O risco continua para quem pode.

## Ajuda e documentação

```bash
oc auth can-i --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

Leitura; nada a desfazer.
