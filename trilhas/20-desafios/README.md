# Trilha 20 — Desafios integradores

> **Status:** disponível · 15 missões · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

A última trilha não ensina comando novo: entrega **requisitos** e pede que você escolha as ferramentas das trilhas
anteriores. Uma loja é construída do zero e depois endurecida, isolada, tornada resiliente, promovida por
ImageStream, levada a dois ambientes com Kustomize, empacotada em Helm, aberta à equipe com RBAC mínimo, ganha
rotina com CronJob e um componente com estado. Fecham a trilha um caso cego com sete defeitos, uma maratona de
casos simultâneos, uma auditoria, uma migração entre projetos e um simulado final cronometrado.

Cada missão traz uma **validação de autoavaliação** (linhas `OK`/`FALHA` produzidas pelas suas próprias
verificações). Não há nota, pontuação nem reprodução de qualquer sistema de correção oficial.

> Prefere só os comandos com a explicação? Veja o [guia direto 20](../../guia/20-desafios.md).

## Pré-requisitos

- Trilhas 00 a 19 (cada missão aponta as trilhas que usa).
- Perfil `developer`. Projetos `ac20-*`.
- **REQUER PREPARAÇÃO:** pull de `registry.access.redhat.com/ubi9/httpd-24` (e `ubi8/httpd-24` na missão 5);
  curinga `*.apps`; cliente `helm` na missão 7 ([docs/11](../../docs/11-preparacao-helm.md)); storage na missão 10
  ([docs/10](../../docs/10-preparacao-storage.md)), com alternativa `emptyDir`.
- O SNO tem recursos limitados: apague os projetos de missões já concluídas antes de começar outra.

## Missões

| ID | Título | Impacto |
|---|---|---|
| [DES-001](exercicios/DES-001.md) | Missão 1: a loja completa, do zero, em 20 minutos | MUTAÇÃO LOCAL |
| [DES-002](exercicios/DES-002.md) | Missão 2: a loja segura | MUTAÇÃO LOCAL |
| [DES-003](exercicios/DES-003.md) | Missão 3: a loja isolada | MUTAÇÃO LOCAL |
| [DES-004](exercicios/DES-004.md) | Missão 4: a loja resiliente | MUTAÇÃO LOCAL |
| [DES-005](exercicios/DES-005.md) | Missão 5: promoção de versões com ImageStream | MUTAÇÃO LOCAL |
| [DES-006](exercicios/DES-006.md) | Missão 6: a loja em dois ambientes com Kustomize | MUTAÇÃO LOCAL |
| [DES-007](exercicios/DES-007.md) | Missão 7: empacotar a loja como chart Helm | MUTAÇÃO LOCAL |
| [DES-008](exercicios/DES-008.md) | Missão 8: acesso da equipe com menor privilégio | MUTAÇÃO LOCAL |
| [DES-009](exercicios/DES-009.md) | Missão 9: rotina de manutenção com CronJob | MUTAÇÃO LOCAL |
| [DES-010](exercicios/DES-010.md) | Missão 10: estado persistente (REQUER PREPARAÇÃO) | MUTAÇÃO LOCAL |
| [DES-011](exercicios/DES-011.md) | Missão 11: diagnóstico cego de uma loja com sete defeitos | MUTAÇÃO LOCAL |
| [DES-012](exercicios/DES-012.md) | Missão 12: maratona — três casos ao mesmo tempo | MUTAÇÃO LOCAL |
| [DES-013](exercicios/DES-013.md) | Missão 13: auditoria da loja | LEITURA |
| [DES-014](exercicios/DES-014.md) | Missão 14: migrar a loja para outro projeto sem perder nada | MUTAÇÃO LOCAL |
| [DES-015](exercicios/DES-015.md) | Missão 15: simulado final cronometrado e encerramento da Academia | MUTAÇÃO LOCAL |

Gabaritos (uma solução possível por missão): [`solucoes/20-desafios/`](../../solucoes/20-desafios/).
Caso cego: [`manifests/casos/desafio-11.yaml`](../../manifests/casos/desafio-11.yaml) — aplique **sem ler**.
Cenários: [TS-061](../../cenarios/troubleshooting/TS-061.md) (HTTP na Route edge),
[TS-062](../../cenarios/troubleshooting/TS-062.md) (SA ausente após migração),
[TS-063](../../cenarios/troubleshooting/TS-063.md) (Job bloqueado pela política de saída).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy show DES-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac20-loja` (a loja das missões) | DES-001 | DES-015 |
| projetos `ac20-loja2`, `ac20-fora` | DES-001, DES-003 | no próprio exercício |
| projetos `ac20-dev`, `ac20-prod`, `ac20-helm`, `ac20-estado` | DES-006, DES-007, DES-010 | no próprio exercício |
| projetos `ac20-cego`, `ac20-maratona`, `ac20-loja-nova` | DES-011, DES-012, DES-014 | no próprio exercício |
| projetos `ac20-final*` | DES-015 | DES-015 |
| arquivos em `/tmp/ac20` (inclui exportações com Secrets fictícios) | DES-001 a DES-014 | DES-014 / DES-015 |
| relatórios em `~/relatorios` | DES-013 | quando você quiser |

Ao final do DES-015 nenhum projeto `ac20-*` deve existir.
