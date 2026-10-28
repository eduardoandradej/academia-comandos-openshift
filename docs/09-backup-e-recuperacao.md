# Backup e recuperação

> A Academia **não executa** nenhuma operação de backup, snapshot ou restauração. Este documento registra o que
> protege o HomeLab, para que os exercícios nunca dependam de "dá para voltar depois".

## O que a Academia garante

- Exercícios só alteram projetos `ac*-*`, com rótulo, e têm limpeza descrita.
- `safe-cleanup.sh` simula por padrão e recusa escopos fora do laboratório.
- Manifestos do repositório são pequenos e reaplicáveis: o "backup" de um exercício é o próprio repositório.

## O que protege o cluster (fora da Academia)

| Camada | Proteção | Situação no checkpoint |
|---|---|---|
| Acesso | kubeconfig `system:admin` do instalador + `kubeadmin` | preservados; não apagar |
| Artefatos de instalação | `install-config.yaml`, `agent-config.yaml`, ISO | guardados fora do Git |
| Estado do cluster | snapshot lógico do etcd pelo procedimento oficial da versão | **não executado ainda** |
| VM inteira | cópia offline do QCOW2 + XML após desligamento controlado | planejado; implica indisponibilidade total do SNO |

Copiar o QCOW2 com a VM ligada **não** é backup consistente do etcd. `virsh snapshot` a quente do nó etcd também
não substitui o procedimento oficial. Cópias de segurança devem ir para o HD (`/mnt/hd1tb`), não para o SSD.

## Recuperação de acesso

Se os perfis `developer`/`admin` deixarem de funcionar (por exemplo, por erro no IdP), o kubeconfig do instalador
continua autenticando por certificado:

```bash
source scripts/perfis.sh && ac-recovery
oc whoami                         # system:admin
oc get co authentication          # leitura
oc get oauth cluster -o jsonpath='{.spec.identityProviders[*].name}{"\n"}'
```

Qualquer correção a partir daí é **VERMELHA**: faça-a manualmente, seguindo a apostila do HomeLab e a documentação
oficial, e volte para `ac-dev` ao terminar.

## Antes de trilhas com uso intenso de disco

Avalie a migração para o SSD novo e confirme mais de 20 GiB livres em `/var` do `kvm-server`
(`scripts/preflight.sh --kvm-ssh <destino>`).
