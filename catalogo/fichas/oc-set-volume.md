# Ficha: `oc set volume` e consumo de ConfigMaps/Secrets

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL · **Perfil mínimo:** developer · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [CFG-002](../../trilhas/08-config/exercicios/CFG-002.md), [CFG-003](../../trilhas/08-config/exercicios/CFG-003.md), [CFG-006](../../trilhas/08-config/exercicios/CFG-006.md), [CFG-010](../../trilhas/08-config/exercicios/CFG-010.md), [CFG-011](../../trilhas/08-config/exercicios/CFG-011.md)

## Quando usar

Para montar ConfigMaps, Secrets (e outros volumes) como arquivos em um workload, ou listar/remover volumes.

## Forma canônica

```bash
oc set volume deployment/ac08-app --add --type=configmap --configmap-name=ac08-arquivo --mount-path=/etc/academia -n ac08-config
```

## Sintaxe

```text
oc set volume deployment/NOME [--add|--remove] [--name=V] [--type=configmap|secret|emptyDir|pvc]
       [--configmap-name=C | --secret-name=S] [--mount-path=/caminho] [--read-only] [--overwrite]
oc set env deployment/NOME --from=configmap/C|secret/S [--prefix=P] [--keys=K1,K2]
```

## Exemplos no HomeLab

```bash
oc set volume deployment/ac08-app -n ac08-config
oc set volume deployment/ac08-app --add --name=cfg-arquivo --type=configmap --configmap-name=ac08-arquivo --mount-path=/etc/academia -n ac08-config
oc set volume deployment/ac08-app --add --name=segredos --type=secret --secret-name=ac08-api --mount-path=/etc/segredos --read-only=true -n ac08-config
oc set volume deployment/ac08-app --remove --name=cfg-arquivo -n ac08-config
oc set env deployment/ac08-app --from=configmap/ac08-env --prefix=CFG_ -n ac08-config
oc rollout restart deployment/ac08-app -n ac08-config
```

## Flags principais

| Flag | Efeito |
|---|---|
| `--add` / `--remove` | acrescenta ou remove o volume e a montagem |
| `--name` | nome do volume no pod |
| `--type` | origem: `configmap`, `secret`, `emptyDir`, `pvc` |
| `--mount-path` | diretório no contêiner (substitui o conteúdo original) |
| `--read-only` | montagem somente leitura |
| `--overwrite` | substitui um volume de mesmo nome |

## Comparação com comandos próximos

| Consumo | Atualiza sozinho? | Observação |
|---|---|---|
| volume | sim (~1 min) | a aplicação precisa reler |
| volume com `subPath` | não | acrescenta um arquivo sem esconder o diretório |
| `env`/`envFrom` | não | exige `rollout restart` |
| `projected` | sim | junta ConfigMap, Secret e Downward API |

## Antes e depois

Depois de montar: `oc exec deploy/<nome> -- ls -la <caminho>`. `items` e `defaultMode` só via YAML/patch.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
deployments/ac08-app
  configMap/ac08-arquivo as cfg-arquivo
    mounted at /etc/academia
  secret/ac08-api as segredos
    mounted at /etc/segredos
```

## Erros comuns

- httpd não inicia após montar em `/etc/httpd/conf.d`: a montagem escondeu os arquivos da imagem (use `subPath`, CFG-010).
- Pod em `ContainerCreating` com `MountVolume.SetUp failed`: ConfigMap/Secret ausente.
- Mudança não aparece: variável ou `subPath` (TS-026).

## Ajuda e documentação

```bash
oc set volume --help
oc set env --help
oc explain pod.spec.volumes.projected
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc set volume ... --remove --name=<volume>`; `oc set env ... VAR-`.
