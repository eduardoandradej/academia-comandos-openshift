# Iniciar aqui

## Em 5 minutos

```bash
# na ocp-admin, como student
git clone https://github.com/eduardoandradej/academia-comandos-openshift.git ~/academia-comandos-openshift
cd ~/academia-comandos-openshift
scripts/academy doctor            # verificação somente leitura
scripts/academy list              # exercícios e cenários disponíveis
scripts/academy show ORI-001      # primeiro exercício
```

Se o `doctor` mostrar `identidade atual: system:admin`, leia [03-identidades-e-rbac.md](03-identidades-e-rbac.md)
antes de continuar: o ORI-004 cria os perfis `developer` e `admin` em kubeconfigs próprios.

## Pré-requisitos

| Item | Situação esperada | Como conferir |
|---|---|---|
| VM `ocp-admin` (RHEL 9.8) com `oc` 4.22, `kubectl`, `jq`, `git` | instalado | `command -v oc kubectl jq git` |
| Cluster SNO 4.22 acessível em `api.ocp.example.lab:6443` | `/readyz` = ok | `oc get --raw /readyz` |
| HTPasswd `homelab-users` com `admin`/`developer` | configurado | ORI-003 |
| Acesso de saída a `registry.access.redhat.com` | necessário a partir de CLI-010/CON-003 | CON-003 |
| `helm` | só na Trilha 14 | `command -v helm` |
| StorageClass | **ausente** — Trilha 09 dependerá de preparação | `scripts/preflight.sh` |

## Ordem recomendada

1. [Trilha 00](../trilhas/00-orientacao/README.md) — base de segurança (não pule o ORI-004).
2. [Trilha 01](../trilhas/01-cli/README.md) — CLI.
3. [Trilha 02](../trilhas/02-consultas/README.md) — leitura e inspeção.
4. [Cenários](../cenarios/troubleshooting/README.md) TS-001 a TS-009 intercalados, conforme a trilha.

## Como estudar cada exercício

1. `scripts/academy show <ID>` e leia **Contexto** e **Pré-flight**.
2. Faça os **Comandos guiados** digitando (não cole).
3. Faça as **Repetições** sem olhar os guiados.
4. Resolva o **Desafio sem pista** e o **Diagnóstico controlado**.
5. **Valide** e **limpe**.
6. Só então abra o gabarito (`scripts/academy where <ID>`).
7. Agende a revisão (`scripts/academy review <ID>`); registre fora do repositório (veja [`progresso/`](../progresso/README.md)).

## Documentos

| Documento | Conteúdo |
|---|---|
| [01-topologia-homelab.md](01-topologia-homelab.md) | máquinas, rede, endpoints e limites |
| [02-preflight-e-seguranca.md](02-preflight-e-seguranca.md) | semáforo de risco, proibições, mecanismos dos scripts |
| [03-identidades-e-rbac.md](03-identidades-e-rbac.md) | usuários de treino, perfis e kubeconfigs |
| [04-diferencas-do-ambiente-redhat.md](04-diferencas-do-ambiente-redhat.md) | sala de aula oficial × HomeLab |
| [05-metodologia-repeticao.md](05-metodologia-repeticao.md) | 6 camadas, 5×/10×/20×, modos e revisão espaçada |
| [06-roteiro-do180.md](06-roteiro-do180.md) | temas DO180 × trilhas |
| [07-roteiro-do280.md](07-roteiro-do280.md) | temas DO280 × trilhas e jornada DO180 → DO280 → EX280 |
| [08-troubleshooting.md](08-troubleshooting.md) | método de diagnóstico |
| [09-backup-e-recuperacao.md](09-backup-e-recuperacao.md) | o que protege o HomeLab e o que esta Academia não faz |
