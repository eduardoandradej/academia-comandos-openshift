# Gabarito SIM-01 — Simulado de administração do cluster

> Uma solução possível por tarefa. Outras soluções que passem em `scripts/simulado/sim-01-verifica.sh` são
> igualmente válidas. Enunciado: [simulados/sim-01/README.md](../../simulados/sim-01/README.md).

## Mapa de revisão

| Tarefa | Competência | Trilha para revisar |
|---|---|---|
| 01 | provedor de identidade HTPasswd | [15](../../trilhas/15-rbac/README.md), [docs/12](../../docs/12-preparacao-usuarios.md) |
| 02, 03, 04 | papéis de cluster e de projeto, grupos | [15](../../trilhas/15-rbac/README.md) |
| 05, 14, 17 | LimitRange, modelo de projeto, ResourceQuota | [17](../../trilhas/17-admin/README.md) |
| 06 | Route edge com certificado próprio | [07](../../trilhas/07-rotas/README.md) |
| 07, 09 | ConfigMap e Secret como variáveis | [08](../../trilhas/08-config/README.md) |
| 08 | Helm com repositório | [14](../../trilhas/14-helm/README.md) |
| 10, 11 | SCC e ServiceAccount | [15](../../trilhas/15-rbac/README.md), [19](../../trilhas/19-troubleshooting/README.md) |
| 12 | OOMKilled e recursos | [04](../../trilhas/04-pods/README.md), [19](../../trilhas/19-troubleshooting/README.md) |
| 13 | NetworkPolicy entre projetos | [16](../../trilhas/16-rede/README.md) |
| 15 | OLM: Subscription, OperatorGroup, InstallPlan | [18](../../trilhas/18-operadores/README.md) |
| 16 | CronJob | [05](../../trilhas/05-deployments/README.md) |

## Tarefa 01 — Provedor HTPasswd adicional

```bash
source scripts/perfis.sh && ac-recovery && oc whoami && ac-admin && oc whoami     # os dois perfis respondem
umask 077; oc get oauth cluster -o yaml > ~/sim-01/oauth-antes.yaml               # backup
htpasswd -c -B ~/sim-01/htpasswd sim-ana                                          # pede a senha (sem -b)
for u in sim-bruno sim-carla sim-davi sim-elisa; do htpasswd -B ~/sim-01/htpasswd "$u"; done
oc create secret generic academia-simulado-htpasswd --from-file=htpasswd="$HOME/sim-01/htpasswd" -n openshift-config
oc label secret academia-simulado-htpasswd -n openshift-config academy.openshift.dev/managed-by=academia academy.openshift.dev/simulado=sim-01
oc patch oauth cluster --type=json -p '[{"op":"add","path":"/spec/identityProviders/-","value":
  {"name":"academia-simulado","mappingMethod":"claim","type":"HTPasswd","htpasswd":{"fileData":{"name":"academia-simulado-htpasswd"}}}}]'
oc get pods -n openshift-authentication -w            # novos pods; Ctrl+C quando estiverem Running
oc get co authentication                              # Available=True, Progressing=False
```

O `add` em `/spec/identityProviders/-` **acrescenta** ao fim da lista: o `homelab-users` continua. Editar o YAML
inteiro e aplicar (`oc replace`) também funciona, mas arrisca apagar o provedor existente por engano.

Teste de login: pelo console, escolha `academia-simulado` na tela de entrada. Pela CLI, use um KUBECONFIG separado
para não perder a sessão admin:

```bash
KUBECONFIG=~/sim-01/ana.kubeconfig oc login -u sim-ana https://api.ocp.example.lab:6443   # senha no prompt
KUBECONFIG=~/sim-01/ana.kubeconfig oc whoami
```

Se a CLI recusar a senha de um usuário do segundo provedor, entre pelo console e use **Copy login command**, ou
`oc login --web`. Com vários provedores HTPasswd, confira na documentação da sua versão qual deles a CLI consulta.

## Tarefa 02 — Permissões de cluster

```bash
oc adm policy add-cluster-role-to-user cluster-admin sim-davi
oc get clusterrolebinding self-provisioners -o yaml > ~/sim-01/self-provisioners-antes.yaml     # backup
oc annotate clusterrolebinding self-provisioners rbac.authorization.kubernetes.io/autoupdate=false --overwrite
oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth
oc adm policy add-cluster-role-to-user self-provisioner sim-elisa
oc auth can-i create projectrequests --as=sim-ana --as-group=system:authenticated:oauth     # no
oc auth can-i create projectrequests --as=sim-elisa --as-group=system:authenticated:oauth   # yes
```

- Sem `autoupdate=false`, o servidor de API devolve o grupo ao binding no próximo reinício.
- Efeito colateral: o `developer` também perde o direito de criar projetos. Por isso esta tarefa fica no fim, e a
  reversão está em `sim-01-limpa.sh`.

Exemplo de `~/sim-01/plano-kubeadmin.md` (não execute):

```markdown
# Plano: remover o kubeadmin
## Antes
- outro cluster-admin do provedor de identidade entra num KUBECONFIG novo e roda `oc get nodes`
- o kubeconfig de recuperação (ac-recovery) foi testado
## Comando
oc delete secret kubeadmin -n kube-system
## Risco
Irreversível: o kubeadmin não volta. Se o provedor de identidade quebrar, só sobra o kubeconfig de recuperação.
```

## Tarefa 03 — Projetos e permissões de projeto

```bash
source scripts/perfis.sh && ac-dev
for p in norte sul leste oeste centro; do oc new-project "ac-sim-$p" --skip-config-write; done
oc adm policy add-role-to-user admin sim-ana -n ac-sim-norte
oc adm policy add-role-to-user admin sim-ana -n ac-sim-leste
oc adm policy add-role-to-user view sim-elisa -n ac-sim-centro
```

O papel `admin` (e não `edit`) é o que permite **administrar** o projeto, inclusive dar acesso a outras pessoas. O
`view` não permite alterar nem apagar.

## Tarefa 04 — Grupos

```bash
ac-admin
oc adm groups new sim-coordenacao sim-ana
oc adm groups new sim-operacao sim-bruno sim-carla
oc label group sim-coordenacao sim-operacao academy.openshift.dev/managed-by=academia academy.openshift.dev/simulado=sim-01
oc adm policy add-role-to-group edit sim-coordenacao -n ac-sim-norte
oc adm policy add-role-to-group view sim-operacao -n ac-sim-norte
```

## Tarefa 05 — LimitRange

```bash
cat <<'YAML' | oc apply -n ac-sim-sul -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: sim-limites
  labels: {academy.openshift.dev/managed-by: academia}
spec:
  limits:
    - type: Pod
      min: {cpu: 10m, memory: 8Mi}
      max: {cpu: 400m, memory: 384Mi}
    - type: Container
      min: {cpu: 10m, memory: 8Mi}
      max: {cpu: 400m, memory: 384Mi}
      defaultRequest: {cpu: 50m, memory: 64Mi}
YAML
oc describe limitrange sim-limites -n ac-sim-sul
```

Sem `default` (limite padrão), o LimitRange usa o `max` como limite padrão do contêiner.

## Tarefa 06 — Route segura

```bash
ac-dev
H=vitrine-segura.apps.ocp.example.lab; C=~/sim-01/certs
scripts/simulado/sim-01-certificado.sh "$H" "/C=BR/ST=SP/L=Campinas/O=Academia/OU=Simulado/CN=$H"
oc delete route vitrine -n ac-sim-vitrine                     # a Route HTTP antiga (o host gerado deixaria de existir)
oc create route edge vitrine --service=vitrine --hostname="$H" \
  --cert="$C/$H.crt" --key="$C/$H.key" --ca-cert="$C/ca.crt" -n ac-sim-vitrine
oc label route vitrine academy.openshift.dev/managed-by=academia -n ac-sim-vitrine
curl --cacert "$C/ca.crt" "https://$H/"                       # vitrine do simulado (sem -k: a CA valida)
```

- `edge`: o TLS termina no router, e o router fala HTTP com o Service.
- "Somente neste endereço": a Route antiga, com o host gerado, precisa sair.

## Tarefa 07 — ConfigMap

```bash
oc create configmap painel-textos --from-literal=SAUDACAO='Bem-vindo ao simulado da Academia' -n ac-sim-painel
oc set env deployment/painel --from=configmap/painel-textos -n ac-sim-painel
oc rollout status deployment/painel -n ac-sim-painel
curl -s "http://$(oc get route painel -n ac-sim-painel -o jsonpath='{.spec.host}')/"
```

O `--from` cria uma variável por chave, cada uma com `configMapKeyRef`. Variáveis de ambiente não se atualizam
sozinhas: se a chave mudar depois, é preciso um novo rollout.

## Tarefa 08 — Helm

```bash
# outro terminal: scripts/simulado/sim-01-helm-repo.sh --servir
helm repo add academia-local http://127.0.0.1:8879 && helm repo update
helm search repo academia-local
oc new-project ac-sim-pacotes --skip-config-write
helm install loja-sim academia-local/ac14-loja -n ac-sim-pacotes --set pagina.conteudo='pacote do simulado' --atomic --timeout 2m
helm test loja-sim -n ac-sim-pacotes
```

## Tarefa 09 — Secret

```bash
read -rs -p 'código do cofre: ' V; echo
oc create secret generic cofre-chave --from-literal=codigo-acesso="$V" -n ac-sim-cofre; unset V
oc set env deployment/cofre --from=secret/cofre-chave -n ac-sim-cofre
oc set env deployment/cofre --list -n ac-sim-cofre             # CODIGO_ACESSO a partir de cofre-chave
curl -s "http://$(oc get route cofre -n ac-sim-cofre -o jsonpath='{.spec.host}')/"   # cofre aberto
```

O `oc set env --from` converte o nome da chave: maiúsculas e `-` → `_` (`codigo-acesso` → `CODIGO_ACESSO`). Pela
Academia, Secret como **arquivo** é preferível (DES-002). Aqui o requisito pede variável, e o valor nunca aparece em
linha de comando.

## Tarefa 10 — ServiceAccount com anyuid

```bash
oc create sa executor-raiz -n ac-sim-raiz
ac-admin
oc adm policy add-scc-to-user anyuid -z executor-raiz -n ac-sim-raiz
oc auth can-i use scc/anyuid -n ac-sim-raiz --as=system:serviceaccount:ac-sim-raiz:executor-raiz   # yes
```

O `-z` restringe a concessão a uma ServiceAccount. Nunca conceda `anyuid` (e muito menos `privileged`) a um grupo
inteiro.

## Tarefa 11 — A aplicação que não sobe

```bash
ac-dev
oc get deployment raiz -n ac-sim-raiz                          # 0/1 e nenhum pod
oc describe rs -n ac-sim-raiz -l app=raiz | sed -n '/Events/,$p'
# FailedCreate: unable to validate against any security context constraint ... runAsUser: 0
oc set serviceaccount deployment/raiz executor-raiz -n ac-sim-raiz
oc rollout status deployment/raiz -n ac-sim-raiz && oc logs deploy/raiz -n ac-sim-raiz   # uid 0
```

Sem pod criado, não há pod para descrever: o erro de admissão fica nos eventos do ReplicaSet (TS-062). O
`runAsUser: 0` continua no Deployment: quem resolve é a SCC escolhida pela SA.

## Tarefa 12 — A aplicação que reinicia

```bash
oc get pods -n ac-sim-memoria -l app=calculo                   # CrashLoopBackOff, reinícios
oc get pods -n ac-sim-memoria -l app=calculo -o jsonpath='{.items[0].status.containerStatuses[0].lastState.terminated.reason}{"\n"}'   # OOMKilled
oc get deployment calculo -n ac-sim-memoria -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
oc set resources deployment/calculo --requests=memory=64Mi --limits=memory=128Mi -n ac-sim-memoria
oc rollout status deployment/calculo -n ac-sim-memoria && oc logs deploy/calculo -n ac-sim-memoria
```

A aplicação reserva 48Mi de uma vez, e o limite era 32Mi. Ajustar recursos não adiciona nem remove componentes.

## Tarefa 13 — NetworkPolicy

```bash
ac-admin && oc label namespace ac-sim-cliente equipe=auditoria && ac-dev
cat <<'YAML' | oc apply -n ac-sim-dados -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: banco-acesso-auditoria
  labels: {academy.openshift.dev/managed-by: academia}
spec:
  podSelector:
    matchLabels: {papel: banco}
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels: {equipe: auditoria}
          podSelector:
            matchLabels: {acesso: leitura-banco}
      ports:
        - {protocol: TCP, port: 8080}
YAML
sleep 15
oc logs deploy/consulta -n ac-sim-cliente --tail=2      # banco: conectado
oc logs deploy/curioso -n ac-sim-intruso --tail=2       # banco: sem resposta
```

`namespaceSelector` e `podSelector` **no mesmo item** de `from` significam "E". Em dois itens separados
(`- namespaceSelector` e `- podSelector`), significariam "OU": qualquer pod de um projeto `equipe=auditoria`, ou
qualquer pod `acesso=leitura-banco` do **próprio** `ac-sim-dados`. O `curioso` continuaria bloqueado, mas a política
ficaria mais aberta do que o pedido.

## Tarefa 14 — Modelo de projeto

```bash
ac-admin
oc adm create-bootstrap-project-template -o json \
  | jq '.metadata.name = "academia-modelo-projeto"
        | .objects += [{"apiVersion":"v1","kind":"LimitRange",
            "metadata":{"name":"${PROJECT_NAME}-limites","labels":{"academy.openshift.dev/managed-by":"academia"}},
            "spec":{"limits":[{"type":"Container","min":{"memory":"128Mi"},"max":{"memory":"384Mi"},
                               "default":{"memory":"256Mi"},"defaultRequest":{"memory":"128Mi"}}]}}]' \
  > ~/sim-01/modelo.json
oc create -f ~/sim-01/modelo.json -n openshift-config
oc patch project.config.openshift.io cluster --type=merge -p '{"spec":{"projectRequestTemplate":{"name":"academia-modelo-projeto"}}}'
oc get pods -n openshift-apiserver -w                  # novos pods; Ctrl+C quando estiverem Running
ac-dev && oc new-project ac-sim-modelo --skip-config-write && oc get limitrange -n ac-sim-modelo
```

`${PROJECT_NAME}` é substituído no momento em que o projeto é criado. Projetos que já existiam não mudam.

## Tarefa 15 — Operador

```bash
ac-admin
oc get packagemanifest openshift-cert-manager-operator -n openshift-marketplace \
  -o jsonpath='{.status.defaultChannel}{"\n"}{.status.channels[0].currentCSVDesc.installModes}{"\n"}'
cat > ~/sim-01/operador.yaml <<'YAML'
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager-operator
  labels:
    openshift.io/cluster-monitoring: "true"
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: cert-manager-operator
  namespace: cert-manager-operator
spec: {}
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-cert-manager-operator
  namespace: cert-manager-operator
spec:
  name: openshift-cert-manager-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  channel: stable-v1                   # use o defaultChannel mostrado acima
  installPlanApproval: Manual
YAML
oc apply --dry-run=server -f ~/sim-01/operador.yaml    # o Namespace valida; os demais acusam que o namespace não existe
```

- `spec: {}` no OperatorGroup = todos os namespaces. Confira se esse modo aparece em `installModes`.
- Instalação real, só com a sua autorização:
  1. `oc apply -f ~/sim-01/operador.yaml`;
  2. `oc get installplan -n cert-manager-operator`;
  3. `oc patch installplan <nome> -n cert-manager-operator --type=merge -p '{"spec":{"approved":true}}'`;
  4. `oc get csv -n cert-manager-operator -w` até `Succeeded`.
- A desinstalação está em `sim-01-limpa.sh`. As CRDs ficam no cluster: remova-as só se nada mais as usar.

## Tarefa 16 — CronJob

```bash
ac-dev
oc new-project ac-sim-rotina --skip-config-write
oc create sa operador-rotina -n ac-sim-rotina
oc create cronjob fechamento-mensal --image=registry.access.redhat.com/ubi9/ubi-minimal:latest \
  --schedule='20 1 10 * *' -n ac-sim-rotina -- /bin/sh -c 'date; echo fechamento concluído'
oc patch cronjob fechamento-mensal -n ac-sim-rotina --type=merge -p '{"spec":{"suspend":true,
  "successfulJobsHistoryLimit":4,"failedJobsHistoryLimit":1,
  "jobTemplate":{"spec":{"template":{"spec":{"serviceAccountName":"operador-rotina"}}}}}}'
oc label cronjob fechamento-mensal academy.openshift.dev/managed-by=academia -n ac-sim-rotina
oc create job fechamento-teste --from=cronjob/fechamento-mensal -n ac-sim-rotina
oc wait --for=condition=complete job/fechamento-teste -n ac-sim-rotina --timeout=90s && oc logs job/fechamento-teste -n ac-sim-rotina
```

A agenda é interpretada em UTC. Para o horário local, use `spec.timeZone: America/Sao_Paulo`.

## Tarefa 17 — ResourceQuota

```bash
ac-admin
oc create quota sim-cota -n ac-sim-centro \
  --hard=requests.cpu=500m,requests.memory=512Mi,pods=5,services=4,replicationcontrollers=2,secrets=12
oc label quota sim-cota academy.openshift.dev/managed-by=academia -n ac-sim-centro
oc describe quota sim-cota -n ac-sim-centro
```

Na quota, `cpu` e `memory` equivalem a `requests.cpu` e `requests.memory`. O verificador aceita as duas formas.
