# Guia direto 10 — Imagens e registries

> Perfil: `developer`. Projeto de treino: `ac10-imagens`. Registry interno desligado no HomeLab: tudo aqui usa a
> imagem de origem. Exercícios completos: [trilhas/10-imagens](../trilhas/10-imagens/README.md).

## 1. Ler uma imagem sem baixá-la — Leitura

```bash
oc image info registry.access.redhat.com/ubi9/httpd-24:latest
oc image info registry.access.redhat.com/ubi9/httpd-24:latest -o json | jq -r .digest
oc image info registry.access.redhat.com/ubi9/httpd-24:latest -o json | jq -c '.config.config | {User, ExposedPorts, Entrypoint, Cmd}'
```

| Parte de `registry.access.redhat.com/ubi9/httpd-24:latest@sha256:...` | O que é |
|---|---|
| `registry.access.redhat.com` | registry (servidor) |
| `ubi9/httpd-24` | repositório |
| `latest` | tag — **pode mudar** de imagem |
| `sha256:...` | digest — identifica o conteúdo, **nunca muda** |

Portas abaixo de 1024 ou imagem que exige root costumam falhar com a SCC `restricted-v2`.

## 2. O que está rodando de verdade — Leitura

```bash
oc new-project ac10-imagens
oc run ac10-um --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac10-imagens
oc get pod ac10-um -n ac10-imagens -o jsonpath='{.spec.containers[0].image}{"\n"}{.status.containerStatuses[0].imageID}{"\n"}'
```

`spec...image` é o pedido; `imageID` é o digest em execução. Se a tag mudou depois, o pod continua no digest antigo.

## 3. Política de pull — Altera

```bash
oc run ac10-ifnp --image=registry.access.redhat.com/ubi9/httpd-24:latest --image-pull-policy=IfNotPresent -n ac10-imagens
oc get events -n ac10-imagens | grep -E 'Pull|already present'
```

| Política | Comportamento | Padrão para |
|---|---|---|
| `Always` | consulta o registry a cada início | `latest` ou sem tag |
| `IfNotPresent` | usa o cache do nó | outras tags e digests |
| `Never` | só o cache; senão `ErrImageNeverPull` | — |

## 4. ImageStream: importar e promover — Altera

```bash
oc create imagestream ac10-web -n ac10-imagens
oc import-image ac10-web:v1 --from=registry.access.redhat.com/ubi9/httpd-24:latest --confirm -n ac10-imagens
oc tag ac10-web:v1 ac10-web:prod -n ac10-imagens            # cópia do digest atual
oc tag --alias ac10-web:v1 ac10-web:atual -n ac10-imagens   # acompanha a v1
oc get istag -n ac10-imagens
oc tag -d ac10-web:atual -n ac10-imagens                    # apaga a tag
```

| Comando | O que faz |
|---|---|
| `oc import-image IS:TAG --from=... --confirm` | grava na tag o digest atual da imagem externa |
| `oc tag A B` | B passa a apontar para a imagem atual de A |
| `oc tag --alias A B` | B segue A sempre |
| `oc tag -d IS:TAG` | remove a tag |

## 5. Usar o ImageStream em um Deployment — Altera

```bash
oc set image-lookup ac10-web -n ac10-imagens
oc create deployment ac10-app --image=ac10-web:prod -n ac10-imagens
oc get pod -n ac10-imagens -l app=ac10-app -o jsonpath='{.items[0].spec.containers[0].image}{"\n"}'
```

Sem `image-lookup`, `ac10-web:prod` vira nome de registry e o pull falha ([TS-031](../cenarios/troubleshooting/TS-031.md)).

## 6. Atualizar sozinho quando a tag muda — Altera

```bash
C=$(oc get deployment ac10-app -n ac10-imagens -o jsonpath='{.spec.template.spec.containers[0].name}')
oc set triggers deployment/ac10-app --from-image=ac10-web:prod --containers="$C" -n ac10-imagens
oc import-image ac10-web:v2 --from=registry.access.redhat.com/ubi8/httpd-24:latest --confirm -n ac10-imagens
oc tag ac10-web:v2 ac10-web:prod -n ac10-imagens            # rollout automático
oc rollout status deployment/ac10-app -n ac10-imagens
```

| Comando | O que faz |
|---|---|
| `oc set triggers --from-image=IS:TAG --containers=C` | troca a imagem do contêiner C quando a tag muda |
| `--manual` / `--auto` | pausa / reativa o gatilho |
| `--remove-all` | remove os gatilhos |

`oc tag ... --scheduled` reimporta a origem periodicamente: com gatilho, isso faz deploy de versões não testadas.

## 7. Registry interno e políticas — Leitura (admin)

```bash
oc get configs.imageregistry.operator.openshift.io cluster -o jsonpath='{.spec.managementState}{"\n"}'
oc get image.config.openshift.io cluster -o jsonpath='{.spec.registrySources}{"\n"}'
oc get imagedigestmirrorsets,imagetagmirrorsets
```

`Removed` = registry desligado: builds, push e `--reference-policy=local` **REQUEREM PREPARAÇÃO**. Mudar políticas
de imagem reinicia o nó: nunca pela Academia.

## 8. Extrair um arquivo de uma imagem — Leitura

```bash
mkdir -p /tmp/ac10
oc image extract registry.access.redhat.com/ubi9/httpd-24:latest --path /etc/httpd/conf/httpd.conf:/tmp/ac10 --filter-by-os=linux/amd64 --confirm
grep -E '^(Listen|DocumentRoot)' /tmp/ac10/httpd.conf
```

## 9. new-app a partir do ImageStream — Altera

```bash
oc new-app --image-stream=ac10-web:prod --name=ac10-novo -n ac10-imagens --dry-run -o yaml | grep '^kind\|  kind'
oc new-app --image-stream=ac10-web:prod --name=ac10-novo -n ac10-imagens
oc delete all -l app=ac10-novo -n ac10-imagens
```

`new-app` cria o Deployment já com gatilho de imagem e um Service para as portas expostas.

## 10. Diagnóstico de pull — Leitura

| Mensagem | Causa | Onde |
|---|---|---|
| `InvalidImageName` | maiúsculas ou caractere inválido; nem tenta baixar | [TS-033](../cenarios/troubleshooting/TS-033.md) |
| `no such host` / `timeout` | registry inacessível | — |
| `manifest unknown` | tag ou repositório inexistente | — |
| `unauthorized` | precisa de pull secret (CFG-008) | — |
| nome curto / `docker.io/library/...` | ImageStream sem image-lookup | [TS-031](../cenarios/troubleshooting/TS-031.md) |
| tag movida, pod igual | gatilho ausente ou pausado | [TS-032](../cenarios/troubleshooting/TS-032.md) |

## 11. Encerrar a trilha — Altera

```bash
oc delete project ac10-imagens
oc get project ac10-imagens      # até NotFound
rm -rf /tmp/ac10
```
