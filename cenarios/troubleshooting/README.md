# Cenários de troubleshooting

> **Progresso:** 36 de 40 cenários planejados · cada um com sintoma, reprodução segura, hipóteses, investigação e gabarito separado.

Modo incidente: você recebe o sintoma, formula hipóteses e as testa com comandos de leitura. A reprodução é sempre
restrita a um único comando ou a um projeto `acNN-*`, com rótulo da Academia e limpeza descrita.

| ID | Cenário | Trilha | Reprodução |
|---|---|---|---|
| [TS-001](TS-001.md) | "Funciona aqui, não funciona lá": o terminal está como system:admin | 00 | LEITURA |
| [TS-002](TS-002.md) | A API "sumiu": no such host, refused ou timeout? | 00 | LEITURA |
| [TS-003](TS-003.md) | Forbidden ao rotular o próprio projeto | 00 | LEITURA |
| [TS-004](TS-004.md) | KUBECONFIG apontando para o vazio | 01 | LEITURA |
| [TS-005](TS-005.md) | Unauthorized depois do almoço | 01 | MUTAÇÃO LOCAL |
| [TS-006](TS-006.md) | No resources found: o namespace errado | 01 | LEITURA |
| [TS-007](TS-007.md) | the server doesn't have a resource type | 02 | LEITURA |
| [TS-008](TS-008.md) | JSONPath que não imprime nada | 02 | LEITURA |
| [TS-009](TS-009.md) | ImagePullBackOff: diagnosticar sem adivinhar | 02 | MUTAÇÃO LOCAL |
| [TS-010](TS-010.md) | Service sem endpoints: o seletor que não casa | 03 | MUTAÇÃO LOCAL |
| [TS-011](TS-011.md) | Projeto preso em Terminating | 03 | MUTAÇÃO LOCAL |
| [TS-012](TS-012.md) | oc label recusou: --overwrite e valores inválidos | 03 | LEITURA |
| [TS-013](TS-013.md) | CrashLoopBackOff: o contêiner sobe e cai | 04 | MUTAÇÃO LOCAL |
| [TS-014](TS-014.md) | Pending para sempre: nenhum nó serve | 04 | MUTAÇÃO LOCAL |
| [TS-015](TS-015.md) | OOMKilled: estourou o limite de memória | 04 | MUTAÇÃO LOCAL |
| [TS-016](TS-016.md) | Rollout travado: a versão nova nunca fica pronta | 05 | MUTAÇÃO LOCAL |
| [TS-017](TS-017.md) | Job que desiste: BackoffLimitExceeded | 05 | MUTAÇÃO LOCAL |
| [TS-018](TS-018.md) | Deployment com menos pods que o pedido: a quota barrou | 05 | MUTAÇÃO LOCAL |
| [TS-019](TS-019.md) | Service com endpoints, mas conexão recusada | 06 | MUTAÇÃO LOCAL |
| [TS-020](TS-020.md) | O nome do Service não resolve em outro projeto | 06 | MUTAÇÃO LOCAL |
| [TS-021](TS-021.md) | Service sem tráfego: o pod roda, mas nunca fica pronto | 06 | MUTAÇÃO LOCAL |
| [TS-022](TS-022.md) | Application is not available: o 503 do router | 07 | MUTAÇÃO LOCAL |
| [TS-023](TS-023.md) | HostAlreadyClaimed: a Route nova não recebe tráfego | 07 | MUTAÇÃO LOCAL |
| [TS-024](TS-024.md) | O hostname da Route não resolve em lugar nenhum | 07 | MUTAÇÃO LOCAL |
| [TS-025](TS-025.md) | CreateContainerConfigError: a configuração que não existe | 08 | MUTAÇÃO LOCAL |
| [TS-026](TS-026.md) | Alterei o ConfigMap e nada mudou | 08 | MUTAÇÃO LOCAL |
| [TS-027](TS-027.md) | Senha certa, autenticação errada: o Secret com bytes a mais | 08 | MUTAÇÃO LOCAL |
| [TS-028](TS-028.md) | PVC que nunca fica Bound (ou nem é criado) | 09 | MUTAÇÃO LOCAL |
| [TS-029](TS-029.md) | Os dados sumiram depois do deploy | 09 | MUTAÇÃO LOCAL |
| [TS-030](TS-030.md) | Pod Evicted: o disco também tem limite | 09 | MUTAÇÃO LOCAL |
| [TS-031](TS-031.md) | ImagePullBackOff com nome curto: o ImageStream que o pod não encontra | 10 | MUTAÇÃO LOCAL |
| [TS-032](TS-032.md) | Mudei a tag e a aplicação continua na versão antiga | 10 | MUTAÇÃO LOCAL |
| [TS-033](TS-033.md) | InvalidImageName: o pod que nem tenta baixar | 10 | MUTAÇÃO LOCAL |
| [TS-034](TS-034.md) | Reinícios em série: a liveness que mata o que está saudável | 11 | MUTAÇÃO LOCAL |
| [TS-035](TS-035.md) | HPA com TARGETS `<unknown>` | 11 | MUTAÇÃO LOCAL |
| [TS-036](TS-036.md) | Evicção recusada: o PDB que trava a manutenção | 11 | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/cenarios/`](../../solucoes/cenarios/). Biblioteca de mensagens: [`catalogo/erros-frequentes.md`](../../catalogo/erros-frequentes.md).
