# Casos de troubleshooting (Trilha 19)

Cada arquivo monta uma aplicação **com defeitos** — normalmente mais de um, em camadas diferentes. Os comentários
dizem só o **sintoma**; os defeitos e as correções ficam nos gabaritos (`solucoes/19-troubleshooting/`).

| Caso | Sintoma | Projeto | Exercício |
|---|---|---|---|
| `caso-01.yaml` | a vitrine nova não responde pelo Service | `ac19-casos` | DIA-003 |
| `caso-02.yaml` | o pod do catálogo nunca fica estável | `ac19-casos` | DIA-004 |
| `caso-03.yaml` | a Route responde "Application is not available" | `ac19-casos` | DIA-005 |
| `caso-04.yaml` | o relatório nunca sai do Pending | `ac19-casos` | DIA-006 |
| `caso-05.yaml` | o robô de escala recebe Forbidden | `ac19-casos` | DIA-007 |
| `caso-06.yaml` | depois do "endurecimento", nada fala com nada | `ac19-rede` | DIA-008 |
| `caso-07.yaml` | pedidos: saudável no início; o defeito vem no exercício | `ac19-casos` | DIA-009 |
| `caso-08.yaml` | o fechamento diário "não roda" | `ac19-casos` | DIA-010 |
| `caso-09.yaml` | duas aplicações reiniciam ou somem sozinhas | `ac19-casos` | DIA-011 |
| `caso-10/` | o overlay de produção não entrega o que promete (renderização) | — | DIA-012 |

Aplique **sem ler** o resto do arquivo; corrija na cópia (`/tmp/ac19`) ou no cluster, nunca no repositório.
Limpeza geral: `oc delete all,cm,sa,role,rolebinding,networkpolicy,cronjob,job -l academy.openshift.dev/managed-by=academia -n <projeto>`.
