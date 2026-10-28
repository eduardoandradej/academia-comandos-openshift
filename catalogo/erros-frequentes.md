# Erros frequentes

> Biblioteca de mensagens: o que significam, o primeiro comando de leitura a rodar e o atalho perigoso a evitar.
> As mensagens são aproximadas; o texto exato varia com a versão.

| Mensagem (trecho) | Significado provável | Primeiro comando | Atalho perigoso a evitar | Onde praticar |
|---|---|---|---|---|
| `Unauthorized` / `You must be logged in` | sessão sem token válido (expirou, logout) | `oc whoami`; `oc login -u <user>` | usar o kubeconfig do instalador "para resolver" | [TS-005](../cenarios/troubleshooting/TS-005.md) |
| `Forbidden ... cannot <verbo> resource` | identidade conhecida, sem permissão | `oc auth can-i <verbo> <recurso> -n <ns>` | dar `cluster-admin` ao usuário | [TS-003](../cenarios/troubleshooting/TS-003.md), ORI-011 |
| `... at the cluster scope` | pediu `-A` ou recurso de cluster sem permissão | `oc auth can-i list <recurso> --all-namespaces` | idem | CON-004 |
| `NotFound` | nome, namespace ou tipo errado; objeto apagado | `oc get <tipo> -n <ns>`; `oc project -q` | recriar às cegas | [TS-006](../cenarios/troubleshooting/TS-006.md) |
| `No resources found in X namespace` | resposta vazia (não é erro) | ler o namespace citado; `oc get ... -n <certo>` | — | TS-006 |
| `the server doesn't have a resource type` | digitação ou tipo não servido (CRD ausente/API removida) | `oc api-resources \| grep -i <parte>` | instalar operadores para "ter o tipo" | [TS-007](../cenarios/troubleshooting/TS-007.md) |
| `no such host` | DNS | `getent ahostsv4 <nome>` | editar DNS do host sem janela de manutenção | [TS-002](../cenarios/troubleshooting/TS-002.md) |
| `connection refused` | host responde, sem serviço na porta | `timeout 3 bash -c '</dev/tcp/<h>/<p>'` | reiniciar a VM do SNO | TS-002 |
| `i/o timeout` / `context deadline exceeded` | sem resposta: rede, VM parada ou API lenta | `time oc get --raw /readyz`; `--request-timeout=10s` | aumentar timeouts em scripts sem investigar | TS-002, CLI-011 |
| `x509: certificate signed by unknown authority` | CA não informada/errada | `openssl s_client ... \| openssl x509 -noout -issuer` | `--insecure-skip-tls-verify` fora do HomeLab | ORI-004 |
| `localhost:8080 was refused` / `Missing or incomplete configuration` | sem kubeconfig válido | `printenv KUBECONFIG`; `oc config get-contexts` | copiar o kubeconfig do instalador para `~/.kube/config` | [TS-004](../cenarios/troubleshooting/TS-004.md) |
| `AlreadyExists` | `create` repetido | `oc get <tipo> <nome> -o yaml` | `delete` + `create` sem verificar dono | ORI-014 |
| `exceeded quota: ac-quota` | admissão de quota recusou | `oc describe quota -n <ns>` | pedir para remover a quota | ORI-013 |
| `ErrImagePull` / `ImagePullBackOff` | tag/repo inexistente, registry inacessível ou sem credencial | `oc describe pod <pod> \| sed -n '/Events:/,$p'` | trocar para imagem aleatória "que funciona" sem entender | [TS-009](../cenarios/troubleshooting/TS-009.md) |
| `CrashLoopBackOff` | o processo do contêiner termina repetidamente | `oc logs <pod> --previous` | aumentar limites às cegas | [TS-013](../cenarios/troubleshooting/TS-013.md), POD-003 |
| `CreateContainerConfigError` | ConfigMap/Secret/chave referenciados ausentes | `oc describe pod` (Events) | criar Secret com valores inventados | [TS-025](../cenarios/troubleshooting/TS-025.md) |
| `Keys [...] were skipped ... invalid environment variable names` | chave do ConfigMap com ponto/hífen não vira variável | `oc get events --field-selector reason=InvalidEnvironmentVariableNames` | renomear chaves usadas como arquivo | CFG-002 |
| Secret "certo" recusado pela aplicação | `\n` final ou base64 duplo no valor | `oc describe secret` (tamanho em bytes) | imprimir o Secret para conferir | [TS-027](../cenarios/troubleshooting/TS-027.md) |
| ConfigMap alterado sem efeito | consumo por variável ou `subPath` | `jq` em `envFrom`/`volumeMounts` | apagar pods um a um | [TS-026](../cenarios/troubleshooting/TS-026.md) |
| `exceeded quota ... persistentvolumeclaims=0` | baseline da Academia proíbe PVCs | `oc describe quota -n <ns>` | pedir para zerar a quota em todos os projetos | [TS-028](../cenarios/troubleshooting/TS-028.md) |
| PVC `Pending`: `no persistent volumes available ... no storage class is set` | sem classe padrão e sem PV compatível | `oc describe pvc`; `oc get sc` | criar PV `hostPath` no nó | [TS-028](../cenarios/troubleshooting/TS-028.md) |
| `Evicted` ... `ephemeral local storage usage exceeds` | pod passou do `limits.ephemeral-storage` | `.status.message` do pod | remover o limite | [TS-030](../cenarios/troubleshooting/TS-030.md) |
| `InvalidImageName` | referência com maiúsculas/caracteres inválidos | `oc get pod -o jsonpath='{.spec.containers[0].image}' \| od -c` | trocar de imagem às cegas | [TS-033](../cenarios/troubleshooting/TS-033.md) |
| `ErrImagePull` com nome de ImageStream (`docker.io/library/<is>`) | ImageStream sem image-lookup | `oc set image-lookup -n <ns>` | qualificar à mão com o registry interno | [TS-031](../cenarios/troubleshooting/TS-031.md) |
| `ErrImageNeverPull` | política `Never` e imagem fora do cache | eventos do pod | — | IMG-004 |
| `Pending` + `FailedScheduling` | sem recursos (requests) ou restrições de agendamento | `oc describe pod`; `oc describe node` (admin) | remover requests/limits; rotular o nó para "encaixar" | [TS-014](../cenarios/troubleshooting/TS-014.md) |
| `OOMKilled` / código 137 | o contêiner passou do `limits.memory` | `oc get pod <pod> -o jsonpath='{.status.containerStatuses[0].lastState}'` | remover o limite de memória | [TS-015](../cenarios/troubleshooting/TS-015.md) |
| código 127 em `oc exec` | o utilitário não existe na imagem | `oc exec <pod> -- sh -c 'command -v <cmd>'` | instalar pacotes dentro do contêiner | POD-006 |
| `Unable to listen on port ... address already in use` | port-forward anterior aberto | `pgrep -af 'oc port-forward'` | — | POD-009 |
| `Readiness probe failed` / `Liveness probe failed` | probe com caminho/porta errados ou app lenta (403 em `/` na UBI) | `oc describe pod` (Events) | desligar probes definitivamente | RES-004, [TS-034](../cenarios/troubleshooting/TS-034.md) |
| HPA `TARGETS <unknown>` | sem `requests.cpu` ou sem Metrics API | `oc describe hpa` (Conditions) | remover o HPA | [TS-035](../cenarios/troubleshooting/TS-035.md) |
| `Cannot evict pod as it would violate the pod's disruption budget` | PDB com `ALLOWED DISRUPTIONS 0` | `oc get pdb` | apagar o PDB sem avisar o dono | [TS-036](../cenarios/troubleshooting/TS-036.md) |
| Route responde `503` | Route sem endpoints prontos (seletor/porta/readiness) | `oc get endpointslices -n <ns>`; `oc describe svc` | apontar a Route direto para o pod | [TS-022](../cenarios/troubleshooting/TS-022.md) |
| Route com `Admitted=False` / `HostAlreadyClaimed` | outra Route mais antiga usa o host | `status.ingress[0].conditions` | apagar Routes de outros | [TS-023](../cenarios/troubleshooting/TS-023.md) |
| `Could not resolve host` para uma Route | hostname fora de `*.apps` ou sem linha no `hosts` do Windows | `getent ahostsv4 <host>`; `curl -H Host:` para 192.168.10.200 | — | [TS-024](../cenarios/troubleshooting/TS-024.md) |
| `SSL certificate problem` ao acessar Route | CA do Ingress não confiável no cliente | `openssl s_client ... \| openssl x509 -noout -issuer` | `-k` fora do HomeLab | RTE-006 |
| `exceeded its progress deadline` | revisão nova não ficou pronta no prazo | condição `Progressing` + pods do RS novo | apagar o Deployment e recriar | [TS-016](../cenarios/troubleshooting/TS-016.md) |
| Job `Failed` / `BackoffLimitExceeded` | a tarefa falhou mais que o `backoffLimit` | `oc logs -l job-name=<job> --prefix` | aumentar o `backoffLimit` sem corrigir a causa | [TS-017](../cenarios/troubleshooting/TS-017.md) |
| `FailedCreate ... exceeded quota` (eventos do ReplicaSet) | quota impediu criar pods | `oc describe rs -l app=<nome>` | pedir para remover a quota | [TS-018](../cenarios/troubleshooting/TS-018.md) |
| `error: timed out waiting for the condition` | `oc wait` expirou | `oc rollout status ... --timeout=5s`; eventos `Warning` | remover o `--timeout` | CON-014 |
| `the object has been modified` | `resourceVersion` antigo no manifesto | `grep resourceVersion <arquivo>` | `--force` | CON-013 |
| `field label not supported` | campo não indexado para `--field-selector` | use jsonpath/jq no cliente | — | CON-006 |
| JSONPath sem saída e sem erro | caminho ou caixa errados; faltou `.items` | `-o json \| jq 'keys'` | — | [TS-008](../cenarios/troubleshooting/TS-008.md) |
| Projeto em `Terminating` por muito tempo | conteúdo/finalizers ainda sendo removidos | condições do namespace (admin) | remover finalizers à mão | ORI-015, [TS-011](../cenarios/troubleshooting/TS-011.md) |
| `Endpoints: <none>` no Service | seletor não casa com os pods (ou pods não prontos) | `oc get pods -l <seletor do svc>` | apontar o Service para IPs fixos | [TS-010](../cenarios/troubleshooting/TS-010.md), [TS-021](../cenarios/troubleshooting/TS-021.md) |
| `Connection refused` com endpoints prontos | `targetPort` diferente da porta do contêiner | `targetPort` × `containerPort` | — | [TS-019](../cenarios/troubleshooting/TS-019.md) |
| nome de Service não resolve (`getent` vazio) | nome curto usado em outro namespace | `grep search /etc/resolv.conf` no pod | — | [TS-020](../cenarios/troubleshooting/TS-020.md) |
| `already has a value ..., and --overwrite is false` | proteção contra sobrescrita de rótulo/anotação | `oc label <obj> --list` | usar `--overwrite` em lote sem conferir | [TS-012](../cenarios/troubleshooting/TS-012.md) |
| `Invalid value: ... a valid label must be ...` | chave/valor com caractere inválido ou longo demais | releia a regex da mensagem | — | TS-012, PRJ-003 |

## Método

1. Leia a mensagem inteira e classifique a camada: sessão, permissão, nome/escopo, rede, admissão, execução.
2. Rode o primeiro comando **de leitura** da tabela.
3. Formule no máximo três hipóteses e teste uma por vez.
4. Corrija dentro do projeto de laboratório; nunca "corrija" mexendo em `openshift-*` ou no nó.

Mais detalhes em [docs/08-troubleshooting.md](../docs/08-troubleshooting.md).
