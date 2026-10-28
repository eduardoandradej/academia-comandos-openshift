# Ficha: `oc set probe`, `oc set resources`, `oc autoscale` e PDB

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [RES-001](../../trilhas/11-resiliencia/exercicios/RES-001.md), [RES-004](../../trilhas/11-resiliencia/exercicios/RES-004.md), [RES-005](../../trilhas/11-resiliencia/exercicios/RES-005.md), [RES-006](../../trilhas/11-resiliencia/exercicios/RES-006.md), [RES-011](../../trilhas/11-resiliencia/exercicios/RES-011.md), [RES-013](../../trilhas/11-resiliencia/exercicios/RES-013.md)

## Quando usar

Para tornar uma aplicação resiliente: recursos corretos, probes que detectam falhas, escala automática e proteção em manutenções.

## Forma canônica

```bash
oc set probe deployment/ac11-app --readiness --open-tcp=8080 -n ac11-resiliencia
```

## Sintaxe

```text
oc set resources deploy/X --requests=cpu=50m,memory=64Mi --limits=cpu=100m,memory=128Mi
oc set probe deploy/X --readiness|--liveness|--startup [--get-url=http://:P/c | --open-tcp=P | -- cmd]
       [--initial-delay-seconds --period-seconds --timeout-seconds --failure-threshold --success-threshold] [--remove]
oc autoscale deploy/X --min=1 --max=2 --cpu-percent=50
oc create poddisruptionbudget NOME --selector=app=X --min-available=1 | --max-unavailable=1
oc adm top pods [--containers] ; oc adm top nodes (admin)
```

## Exemplos no HomeLab

```bash
oc set resources deployment/ac11-app --requests=cpu=50m,memory=64Mi --limits=cpu=100m,memory=128Mi -n ac11-resiliencia
oc set probe deployment/ac11-app --readiness --open-tcp=8080 --period-seconds=5 -n ac11-resiliencia
oc set probe deployment/ac11-app --liveness --period-seconds=10 --failure-threshold=3 -n ac11-resiliencia -- test -d /var/www/html
oc set probe deployment/ac11-lento --startup --open-tcp=8080 --period-seconds=2 --failure-threshold=30 -n ac11-resiliencia
oc autoscale deployment/ac11-app --min=1 --max=2 --cpu-percent=50 -n ac11-resiliencia
oc create poddisruptionbudget ac11-pdb --selector=app=ac11-app --min-available=1 -n ac11-resiliencia
oc adm top pods -n ac11-resiliencia --containers
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--get-url` / `--open-tcp` / `-- cmd` | tipo da probe (HTTP 200–399, porta aberta, comando com saída 0) |
| `--period-seconds` × `--failure-threshold` | tempo até agir |
| `--timeout-seconds` | tempo máximo por verificação (padrão 1 s) |
| `--remove` | remove a probe indicada |
| `--cpu-percent` | alvo do HPA, relativo ao `requests.cpu` |

## Comparação com comandos próximos

| Probe | Ao falhar | Use para |
|---|---|---|
| readiness | sai do Service | "ainda não posso atender" |
| liveness | reinicia o contêiner | travamento que a aplicação não percebe |
| startup | segura as outras; reinicia se nunca passar | inicialização lenta |

## Antes e depois

Depois de configurar: `oc rollout status`, eventos `Unhealthy`, `oc get hpa` (TARGETS) e `oc get pdb` (ALLOWED DISRUPTIONS).

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
NAME       REFERENCE             TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
ac11-app   Deployment/ac11-app   12%/50%   1         2         1          3m
```

## Erros comuns

- `Readiness probe failed: ... statuscode: 403`: caminho sem conteúdo na UBI; use TCP (RES-004).
- `Liveness probe failed: command timed out`: `timeoutSeconds` curto (TS-034).
- `TARGETS <unknown>`: sem `requests.cpu` ou sem Metrics API (TS-035).
- `Cannot evict pod ... disruption budget`: `ALLOWED DISRUPTIONS 0` (TS-036).
- `maximum ... per Container is 512Mi`: acima do LimitRange (RES-001).

## Ajuda e documentação

```bash
oc set probe --help
oc set resources --help
oc autoscale --help
oc create poddisruptionbudget --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc set probe ... --remove`; `oc delete hpa <nome>`; `oc delete pdb <nome>`; `oc rollout undo`.
