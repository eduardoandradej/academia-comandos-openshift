# Trilha 15 — Usuários, identidade e RBAC

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Quem pode fazer o quê: identidade da sessão, `can-i` com subrecursos e impersonação, papéis `view`/`edit`/`admin`,
RoleBindings por dentro, Roles mínimas, ClusterRoles usadas em um projeto, grupos, service accounts e tokens curtos,
escopo de cluster (só dry-run), auditoria, self-provisioning, SCC como permissão, provedores de identidade e o
roteiro para ler um Forbidden.

> Prefere só os comandos com a explicação? Veja o [guia direto 15](../../guia/15-rbac.md).

## Pré-requisitos

- Trilhas 00–03 (perfis, projetos, rótulos) e CFG-014.
- Perfis `developer` e `admin` do ORI-004. O `admin` é usado em RBC-006, RBC-007, RBC-009, RBC-011, RBC-013 e TS-048.
- **Sem usuários novos:** os testes usam service accounts e impersonação (`--as`). Acrescentar usuários do DO280 ao
  HTPasswd é **VERMELHO**, manual e opcional: [docs/12-preparacao-usuarios.md](../../docs/12-preparacao-usuarios.md).
- Nada de `ClusterRoleBinding`, SCC `anyuid`/`privileged` ou mudança no OAuth: esses aparecem só em leitura ou `--dry-run`.
- Objetos de cluster da trilha (grupos, ClusterRoles) levam `academy.openshift.dev/trilha=15` e são removidos por rótulo no RBC-015.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [RBC-001](exercicios/RBC-001.md) | Quem sou eu para a API: usuário, grupos e permissões | LEITURA |
| [RBC-002](exercicios/RBC-002.md) | can-i em profundidade: verbos, subrecursos e outra identidade | MUTAÇÃO LOCAL |
| [RBC-003](exercicios/RBC-003.md) | Os papéis padrão do projeto: view, edit e admin | MUTAÇÃO LOCAL |
| [RBC-004](exercicios/RBC-004.md) | RoleBindings por dentro: sujeitos, roleRef e auditoria | MUTAÇÃO LOCAL |
| [RBC-005](exercicios/RBC-005.md) | Role própria com o mínimo necessário | MUTAÇÃO LOCAL |
| [RBC-006](exercicios/RBC-006.md) | ClusterRole usada dentro de um projeto | MUTAÇÃO DE CLUSTER (rotulada) |
| [RBC-007](exercicios/RBC-007.md) | Grupos: conceder a uma equipe, não a pessoas | MUTAÇÃO DE CLUSTER (rotulada) |
| [RBC-008](exercicios/RBC-008.md) | Service accounts: identidade dos pods e tokens de curta duração | MUTAÇÃO LOCAL |
| [RBC-009](exercicios/RBC-009.md) | Escopo de cluster: o que nunca se concede por engano | LEITURA |
| [RBC-010](exercicios/RBC-010.md) | Auditoria de acesso a um projeto | LEITURA |
| [RBC-011](exercicios/RBC-011.md) | Quem pode criar projetos: self-provisioner (somente leitura) | LEITURA |
| [RBC-012](exercicios/RBC-012.md) | SCC e RBAC: por que o pod não roda como root | LEITURA |
| [RBC-013](exercicios/RBC-013.md) | Identidades e o provedor OAuth (leitura) e o roteiro HTPasswd | LEITURA |
| [RBC-014](exercicios/RBC-014.md) | Roteiro de diagnóstico de Forbidden | LEITURA |
| [RBC-015](exercicios/RBC-015.md) | Circuito de RBAC e encerramento da trilha | MUTAÇÃO LOCAL |

Gabaritos: [`solucoes/15-rbac/`](../../solucoes/15-rbac/). Fichas:
[`oc-policy-rbac`](../../catalogo/fichas/oc-policy-rbac.md), [`oc-auth-can-i`](../../catalogo/fichas/oc-auth-can-i.md).
Cenários: [TS-046](../../cenarios/troubleshooting/TS-046.md) (subrecurso `pods/log`),
[TS-047](../../cenarios/troubleshooting/TS-047.md) (`roleRef` imutável),
[TS-048](../../cenarios/troubleshooting/TS-048.md) (grupo com nome errado no binding).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 15
scripts/academy show RBC-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac15-rbac`, SAs `ac15-leitor` e `ac15-robo`, Roles e RoleBindings | RBC-002 a RBC-005 | RBC-015 |
| ClusterRole `ac15-leitor-configmaps` (admin) | RBC-006 | RBC-015 |
| projeto `ac15-alheio` e grupo `ac15-equipe` (admin) | RBC-007 | RBC-015 |
| grupo `ac15-auditores` (admin) | RBC-007 (desafio) | RBC-007 |
| tokens de SA | RBC-008 | expiram sozinhos (10 min); nunca gravados em disco |
