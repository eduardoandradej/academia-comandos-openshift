# Trilha 00 — Orientação e segurança

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Antes de praticar comandos em volume, é preciso saber **onde** você está, **quem** você é para o cluster, **o que**
o SNO aguenta e **como** desfazer o que fizer. Esta trilha monta essa base: perfis separados por kubeconfig, leitura
de saúde do cluster, semáforo de risco, projeto de treino com cota e limpeza previsível.

## O que você vai dominar

- Diferenciar `ocp-admin`, `ocp-sno` e `kvm-server`, e usuário Linux × identidade no cluster.
- Reconhecer o kubeconfig do instalador (`system:admin`) e trabalhar com perfis `developer` e `admin` dedicados.
- Ler `/readyz`, `ClusterVersion`, nó, Cluster Operators e capacidade sem alterar nada.
- Classificar comandos em VERDE / AMARELO / VERMELHO e checar permissões com `oc auth can-i`.
- Criar o projeto `ac00-orientacao`, aplicar a baseline de cota e limpar tudo com `scripts/safe-cleanup.sh`.

## Pré-requisitos

| Item | Como conferir | Se faltar |
|---|---|---|
| `oc` 4.22, `kubectl`, `jq` na `ocp-admin` | `command -v oc kubectl jq` | instalar antes (fora do escopo) |
| API acessível | `oc get --raw /readyz` | ver ORI-005 e CLI-014 |
| HTPasswd `homelab-users` com `admin` e `developer` | ORI-003 | **REQUER PREPARAÇÃO** — apostila do HomeLab, seção 12.1 (mudança de cluster, manual) |
| Imagens externas | — | não usadas nesta trilha |

## Exercícios

| ID | Título | Perfil | Impacto |
|---|---|---|---|
| [ORI-001](exercicios/ORI-001.md) | Onde estou: máquina, usuário e cliente oc | local | LEITURA |
| [ORI-002](exercicios/ORI-002.md) | Quem sou eu para o cluster? KUBECONFIG e identidade | o atual | LEITURA |
| [ORI-003](exercicios/ORI-003.md) | admin e developer existem? Conferir o provedor HTPasswd | admin | LEITURA |
| [ORI-004](exercicios/ORI-004.md) | Um kubeconfig dedicado para cada perfil | developer, admin | MUTAÇÃO LOCAL |
| [ORI-005](exercicios/ORI-005.md) | Saúde da API sem privilégios | developer | LEITURA |
| [ORI-006](exercicios/ORI-006.md) | ClusterVersion e o nó único | admin | LEITURA |
| [ORI-007](exercicios/ORI-007.md) | Cluster Operators: ler sem tocar | admin | LEITURA |
| [ORI-008](exercicios/ORI-008.md) | Capacidade do SNO antes de praticar | admin | LEITURA |
| [ORI-009](exercicios/ORI-009.md) | Preflight do repositório e academy doctor | developer, admin | LEITURA |
| [ORI-010](exercicios/ORI-010.md) | Semáforo de risco: VERDE, AMARELO e VERMELHO | developer | LEITURA |
| [ORI-011](exercicios/ORI-011.md) | Criar o projeto de treino ac00-orientacao | developer | MUTAÇÃO LOCAL |
| [ORI-012](exercicios/ORI-012.md) | Baseline de cotas e limites no projeto de treino | admin | MUTAÇÃO LOCAL |
| [ORI-013](exercicios/ORI-013.md) | Ler cotas e limites como developer | developer | LEITURA |
| [ORI-014](exercicios/ORI-014.md) | Pensar antes de mutar: can-i, dry-run e rótulos | developer | MUTAÇÃO LOCAL |
| [ORI-015](exercicios/ORI-015.md) | Encerramento seguro da trilha | developer | MUTAÇÃO LOCAL |

Faça na ordem: ORI-004 cria os perfis usados por todos os exercícios seguintes, e ORI-011 → ORI-015 formam um ciclo
completo (criar → proteger → usar → limpar). Os gabaritos ficam em [`solucoes/00-orientacao/`](../../solucoes/00-orientacao/).

## Como começar

```bash
cd ~/academia-comandos-openshift
scripts/academy list --trilha 00     # lista os exercícios
scripts/academy show ORI-001         # mostra o enunciado (sem gabarito)
scripts/academy doctor               # preflight somente leitura
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| `~/.kube/ac-developer.kubeconfig`, `~/.kube/ac-admin.kubeconfig`, `~/.kube/ocp-sno-ca.crt` | ORI-004 | permanecem (usados em todas as trilhas) |
| projeto `ac00-orientacao` + `ac-quota` + `ac-limits` | ORI-011, ORI-012 | ORI-015 |
| projetos `ac00-rascunho`, `ac00-ciclo` | ORI-011, ORI-015 | no próprio exercício |
| ConfigMaps `ac00-*` | ORI-014 | ORI-014 |

Nenhum exercício altera `openshift-*`, `kube-*`, o nó, o OAuth ou o host.
