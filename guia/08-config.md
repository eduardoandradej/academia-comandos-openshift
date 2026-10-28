# Guia direto 08 — ConfigMaps e Secrets

> Perfil: `developer`. Projeto de treino: `ac08-config`. Todos os Secrets usam **valores fictícios**.
> Exercícios completos: [trilhas/08-config](../trilhas/08-config/README.md).

## 1. Preparar o projeto e os arquivos — Altera

```bash
oc new-project ac08-config
mkdir -p /tmp/ac08
printf 'Listen 8080\nServerName academia\n' > /tmp/ac08/app.conf
printf 'MODO=treino\nNIVEL_LOG=info\nCOR=azul\n' > /tmp/ac08/app.env
```

## 2. Criar ConfigMaps — Altera

```bash
oc create configmap ac08-literal --from-literal=MODO=treino --from-literal=NIVEL_LOG=debug -n ac08-config
oc create configmap ac08-arquivo --from-file=principal.conf=/tmp/ac08/app.conf -n ac08-config
oc create configmap ac08-env --from-env-file=/tmp/ac08/app.env -n ac08-config
oc get configmap ac08-env -n ac08-config -o jsonpath='{.data}{"\n"}'
```

| Comando | O que faz |
|---|---|
| `--from-literal=K=V` | uma chave por par |
| `--from-file=chave=arquivo` | o arquivo inteiro vira o valor da chave (sem `chave=`, usa o nome do arquivo) |
| `--from-env-file=arquivo` | cada linha `K=V` vira uma chave (não combina com as outras origens) |
| `-o jsonpath='{.data}'` | mostra as chaves e os valores |

## 3. Usar como variáveis de ambiente — Altera

```bash
oc create deployment ac08-app --image=registry.access.redhat.com/ubi9/httpd-24:latest -n ac08-config
oc set env deployment/ac08-app --from=configmap/ac08-literal -n ac08-config
oc set env deployment/ac08-app --from=configmap/ac08-env --prefix=CFG_ -n ac08-config
oc rollout status deployment/ac08-app -n ac08-config
oc exec deploy/ac08-app -n ac08-config -- env | grep -E '^(MODO|CFG_)'
```

| Comando | O que faz |
|---|---|
| `oc set env --from=configmap/X` | cada chave vira uma variável (`envFrom`) |
| `--prefix=CFG_` | as variáveis ganham o prefixo (`CFG_COR`) |
| `oc exec ... -- env` | confirma dentro do contêiner |

Chaves com ponto (`app.conf`) não viram variáveis: são ignoradas com um evento de aviso.

## 4. Usar como arquivos — Altera

```bash
oc set volume deployment/ac08-app --add --name=cfg-arquivo --type=configmap \
  --configmap-name=ac08-arquivo --mount-path=/etc/academia -n ac08-config
oc rollout status deployment/ac08-app -n ac08-config
oc exec deploy/ac08-app -n ac08-config -- ls -la /etc/academia
oc set volume deployment/ac08-app -n ac08-config        # lista os volumes
```

| Comando | O que faz |
|---|---|
| `oc set volume --add --type=configmap` | monta o ConfigMap; cada chave vira um arquivo |
| `--mount-path` | diretório no contêiner (o conteúdo original dele fica escondido) |
| `oc set volume` sem flags | lista volumes e montagens |
| `--remove --name=X` | remove o volume |

## 5. O que se atualiza sozinho — Altera

```bash
oc set data configmap/ac08-literal MODO=producao -n ac08-config
oc exec deploy/ac08-app -n ac08-config -- printenv MODO       # ainda treino
oc rollout restart deployment/ac08-app -n ac08-config
oc rollout status deployment/ac08-app -n ac08-config
oc exec deploy/ac08-app -n ac08-config -- printenv MODO       # producao
```

| Consumo | Atualiza quando o ConfigMap muda? |
|---|---|
| arquivo (volume) | sim, em até ~1 minuto |
| arquivo com `subPath` | não |
| variável de ambiente | não: precisa de `oc rollout restart` |

## 6. Secrets sem expor valores — Altera

```bash
oc create secret generic ac08-banco --from-literal=usuario=treino --from-literal=senha=senha-de-treino -n ac08-config
read -rs -p 'token fictício: ' T; echo
oc create secret generic ac08-api --from-literal=token="$T" -n ac08-config; unset T
oc describe secret ac08-banco -n ac08-config
oc get secret ac08-banco -n ac08-config -o json | jq -r '.data | keys[]'
```

| Comando | O que faz |
|---|---|
| `oc create secret generic` | Secret com as mesmas origens do ConfigMap |
| `read -rs` | lê o valor sem eco e sem deixá-lo no histórico do shell |
| `oc describe secret` | mostra chaves e **tamanho em bytes**, nunca os valores |
| `jq '.data \| keys'` | só os nomes das chaves |

Base64 **não é criptografia**: `oc get secret -o yaml` + `base64 -d` revela o valor. Quem protege o Secret é o RBAC.

## 7. Consumir Secrets — Altera

```bash
oc set env deployment/ac08-app --from=secret/ac08-banco --prefix=DB_ -n ac08-config
oc set volume deployment/ac08-app --add --name=segredos --type=secret --secret-name=ac08-api \
  --mount-path=/etc/segredos --read-only=true -n ac08-config
oc rollout status deployment/ac08-app -n ac08-config
oc exec deploy/ac08-app -n ac08-config -- sh -c 'ls -lL /etc/segredos; wc -c < /etc/segredos/token'
```

Prefira arquivos: variáveis aparecem para qualquer processo do contêiner e para quem faz `oc exec ... env`.

## 8. Secret TLS e pull secret — Altera

```bash
openssl req -x509 -newkey rsa:2048 -nodes -days 7 -keyout /tmp/ac08/tls.key -out /tmp/ac08/tls.crt \
  -subj "/CN=ac08.apps.ocp.example.lab" 2>/dev/null
oc create secret tls ac08-tls --cert=/tmp/ac08/tls.crt --key=/tmp/ac08/tls.key -n ac08-config
read -rs -p 'senha fictícia: ' S; echo
oc create secret docker-registry ac08-pull --docker-server=registry.exemplo.invalid \
  --docker-username=treino --docker-password="$S" -n ac08-config; unset S
oc secrets link default ac08-pull --for=pull -n ac08-config
oc get sa default -n ac08-config -o jsonpath='{.imagePullSecrets}{"\n"}'
oc secrets unlink default ac08-pull -n ac08-config
```

| Comando | O que faz |
|---|---|
| `oc create secret tls` | Secret `kubernetes.io/tls` (`tls.crt` + `tls.key`); confere se formam um par |
| `oc create secret docker-registry` | credencial de registry (`kubernetes.io/dockerconfigjson`) |
| `oc secrets link ... --for=pull` | a service account passa a usar o Secret para baixar imagens |
| `oc secrets unlink` | desfaz o vínculo |

O registry `registry.exemplo.invalid` não existe: é só para praticar o mecanismo.

## 9. Imutável e subPath — Altera

```bash
oc create configmap ac08-fixo-v1 --from-literal=VERSAO=1 --dry-run=client -o json \
  | jq '.immutable=true' | oc apply -n ac08-config -f -
oc set data configmap/ac08-fixo-v1 VERSAO=2 -n ac08-config      # recusado
oc create configmap ac08-httpd --from-literal=academia.conf='Header always set X-Academia "treino"' -n ac08-config
```

| Conceito | O que significa |
|---|---|
| `immutable: true` | ninguém altera os dados; para mudar, crie `-v2` e troque a referência |
| `subPath` | monta um único arquivo (por exemplo, `conf.d/academia.conf`) sem esconder o diretório; **não** se atualiza |

O `subPath` só é definido por YAML ou `oc patch` (exemplo completo no [CFG-010](../trilhas/08-config/exercicios/CFG-010.md)).

## 10. Extrair e atualizar — Altera

```bash
oc extract configmap/ac08-arquivo --to=/tmp/ac08/extraido -n ac08-config --confirm
oc set data configmap/ac08-arquivo --from-file=principal.conf=/tmp/ac08/extraido/principal.conf -n ac08-config
oc set data configmap/ac08-literal NIVEL_LOG- -n ac08-config    # remove a chave
oc create configmap ac08-env --from-env-file=/tmp/ac08/app.env --dry-run=client -o yaml | oc diff -n ac08-config -f -
oc create configmap ac08-env --from-env-file=/tmp/ac08/app.env --dry-run=client -o yaml | oc apply -n ac08-config -f -
```

| Comando | O que faz |
|---|---|
| `oc extract --to=dir` | grava cada chave como arquivo (`--confirm` sobrescreve) |
| `oc set data K=V` / `K-` | altera ou remove só as chaves citadas |
| `create --dry-run -o yaml \| oc diff` | mostra o que mudaria |
| `create --dry-run -o yaml \| oc apply` | cria ou atualiza de forma idempotente |

Com Secrets, `oc extract` grava os valores em disco: só com dados fictícios, e apague logo depois.

## 11. Quem pode ler Secrets — Leitura

```bash
oc auth can-i get secrets -n ac08-config
oc auth can-i create pods/exec -n ac08-config
```

| Papel no projeto | Lê Secrets? |
|---|---|
| `view` | não |
| `edit`, `admin` | sim |

Também enxerga os valores quem pode fazer `oc exec` (variáveis e arquivos) ou criar pods no projeto (pode montar qualquer Secret).

## 12. Diagnóstico — Leitura

| Sintoma | Causa típica | Cenário |
|---|---|---|
| `CreateContainerConfigError` | ConfigMap, Secret ou chave referenciados não existem | [TS-025](../cenarios/troubleshooting/TS-025.md) |
| mudei o ConfigMap e nada mudou | consumo por variável ou `subPath` | [TS-026](../cenarios/troubleshooting/TS-026.md) |
| senha "certa" recusada | `\n` do `echo` ou base64 duplo (veja os bytes no `describe`) | [TS-027](../cenarios/troubleshooting/TS-027.md) |
| `ContainerCreating` com `MountVolume.SetUp failed` | volume aponta para um objeto ausente | — |
| httpd não sobe após montar em `conf.d` | a montagem escondeu os arquivos da imagem | use `subPath` |

## 13. Encerrar a trilha — Altera

```bash
oc delete project ac08-config
oc get project ac08-config      # até NotFound
rm -rf /tmp/ac08
```
