# Scripts

Utilitários locais para a `ocp-admin`. Nenhum exige root. Nenhum é o `lab` da Red Hat, e nenhum atribui nota.

| Script | Impacto | Uso |
|---|---|---|
| [`academy`](academy) | LEITURA | `doctor`, `list [--trilha NN]`, `show ID`, `review ID`, `where ID`, `version`, `help` |
| [`preflight.sh`](preflight.sh) | LEITURA | verificação do HomeLab; `--kvm-ssh DESTINO` consulta `/var` do host (opcional) |
| [`status.sh`](status.sh) | LEITURA | projetos de laboratório e recursos rotulados; `-n NS` detalha |
| [`safe-cleanup.sh`](safe-cleanup.sh) | simula por padrão; `--execute` = MUTAÇÃO LOCAL | apaga só recursos rotulados em `ac*-*`; `--delete-project` com prova de propriedade |
| [`perfis.sh`](perfis.sh) | local | `source` para ter `ac-dev`, `ac-admin`, `ac-recovery`, `ac-perfil` |
| [`lib/common.sh`](lib/common.sh) | — | funções compartilhadas (rótulo, regex de namespace, saída) |
| [`dev/check-repo.sh`](dev/check-repo.sh) | local | validação estática do repositório (CI) |
| [`simulado/sim-01-prepara.sh`](simulado/sim-01-prepara.sh) | simula por padrão; `--execute` = MUTAÇÃO LOCAL | cria os projetos `ac-sim-*` e as aplicações iniciais do SIM-01 |
| [`simulado/sim-01-verifica.sh`](simulado/sim-01-verifica.sh) | LEITURA | autoavaliação do SIM-01 (`--tarefa N`); OK/FALHA/PULADO, sem nota |
| [`simulado/sim-01-certificado.sh`](simulado/sim-01-certificado.sh) | local | CA de treino e certificado para a tarefa 06 (fora do repositório) |
| [`simulado/sim-01-helm-repo.sh`](simulado/sim-01-helm-repo.sh) | local | repositório Helm em `127.0.0.1:8879` para a tarefa 08 |
| [`simulado/sim-01-limpa.sh`](simulado/sim-01-limpa.sh) | simula por padrão; `--execute` = MUTAÇÃO LOCAL | apaga os projetos `ac-sim-*`; imprime a reversão manual de cluster |

Subcomandos `academy start|status|check|finish` ainda **não** estão implementados: serão liberados somente depois de
testes de idempotência e de escopo.

Códigos de saída: `0` sucesso · `1` falha de verificação · `2` erro de uso/recusa de segurança · `3` não implementado.
