# Ficha: `oc rollout`

> **Impacto:** LEITURA (status, history) · MUTAÇÃO LOCAL (undo, restart, pause, resume) · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [DEP-003](../../trilhas/05-deployments/exercicios/DEP-003.md), [DEP-004](../../trilhas/05-deployments/exercicios/DEP-004.md), [DEP-005](../../trilhas/05-deployments/exercicios/DEP-005.md), [DEP-014](../../trilhas/05-deployments/exercicios/DEP-014.md)

## Quando usar

Para acompanhar, inspecionar, desfazer, reiniciar e agrupar atualizações de Deployments (e DaemonSets/StatefulSets).

## Forma canônica

```bash
oc rollout status deployment/ac05-web -n ac05-deploy
```

## Sintaxe

```text
oc rollout status | history [--revision=N] | undo [--to-revision=N] | restart | pause | resume  TIPO/NOME
```

## Exemplos no HomeLab

```bash
oc rollout status deployment/ac05-web -n ac05-deploy --timeout=120s
oc rollout history deployment/ac05-web -n ac05-deploy
oc rollout history deployment/ac05-web --revision=2 -n ac05-deploy
oc rollout undo deployment/ac05-web --to-revision=2 -n ac05-deploy
oc rollout restart deployment/ac05-web -n ac05-deploy
oc rollout pause deployment/ac05-web -n ac05-deploy
oc rollout resume deployment/ac05-web -n ac05-deploy
```

## Flags principais

| Subcomando | Efeito |
|---|---|
| `status` | espera o rollout terminar (código ≠ 0 se falhar ou expirar) |
| `history` | lista revisões; `--revision=N` mostra o template |
| `undo` | volta à revisão anterior ou `--to-revision` |
| `restart` | recria os pods com o mesmo template |
| `pause` / `resume` | acumula mudanças / aplica de uma vez |

## Comparação com comandos próximos

| Comando | Muda o template? | Revisão nova? |
|---|---|---|
| `rollout restart` | só a anotação `restartedAt` | sim |
| `rollout undo` | volta ao de uma revisão anterior | reaproveita a antiga (com número novo) |
| `scale` | não | não |

## Antes e depois

Registre o motivo com `oc annotate deployment/<nome> kubernetes.io/change-cause='...' --overwrite`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
REVISION  CHANGE-CAUSE
2         v2: VERSAO=v2
3         v3: VERSAO=v3
```

## Erros comuns

- `exceeded its progress deadline`: a revisão nova não ficou pronta; investigue e use `undo` (TS-016).
- `can't undo paused deployment`: faça `resume` antes.
- `unable to find specified revision`: revisão reaproveitada ou além do `revisionHistoryLimit`.

## Ajuda e documentação

```bash
oc rollout --help
oc rollout undo --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc rollout undo` desfaz uma revisão; `resume` desfaz um `pause`.
