# Diferenças entre a sala de aula Red Hat e o HomeLab

| Sala oficial (DO180/DO280) | HomeLab | Consequência |
|---|---|---|
| `workstation.lab.example.com` | `ocp-admin` (192.168.122.95) | os comandos rodam aqui |
| `master01.lab.example.com` (SNO) | `ocp-sno.ocp.example.lab` (192.168.10.200) | mesma topologia de nó único |
| API `api.lab.example.com` | `api.ocp.example.lab:6443` | troque **só o endpoint**, não usuários/senhas |
| Domínio de apps `apps.lab.example.com` | `apps.ocp.example.lab` | Routes recebem esse sufixo |
| `utility`, `classroom` | parte no `kvm-server` (DNS) | NFS/DHCP de sala não existem |
| `registry.lab.example.com` | não implantado | usar registries públicos; exercícios com registry privado: **REQUER PREPARAÇÃO** |
| `idm.lab.example.com` (LDAP) | HTPasswd `homelab-users` | exercícios de LDAP: **NÃO DISPONÍVEL NO HOME LAB ATUAL** |
| `lab start / grade / finish` | **não existe** | a Academia oferece `academy` (sem nota) e `safe-cleanup.sh` |
| Storage de sala | 0 StorageClasses | PV/PVC dinâmico: **REQUER PREPARAÇÃO** |
| LoadBalancer / redes adicionais | ausentes | tratados de forma conceitual |

## O que a Academia não faz

- Não reproduz, copia nem imita os scripts `lab` da Red Hat, nem seus roteiros, figuras ou textos.
- Não atribui notas: `academy` faz verificações explicativas, sem pontuação.
- Não promete equivalência com exames nem aprovação.
- Não substitui o curso, a infraestrutura ou a documentação oficiais.
