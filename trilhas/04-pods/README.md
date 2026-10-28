# Trilha 04 — Pods e contêineres

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

O dia a dia com pods: criar, acompanhar o ciclo de vida, ler logs, entrar no contêiner, copiar arquivos, abrir túneis,
controlar comando e variáveis, entender QoS, investigar com `oc debug` e ligar o pod ao contêiner real no CRI-O.

> Prefere só os comandos com a explicação? Veja o [guia direto 04](../../guia/04-pods.md).

## Pré-requisitos

- Trilhas 00–03 (perfis, projetos, consultas, rótulos).
- **REQUER PREPARAÇÃO:** o cluster precisa baixar `registry.access.redhat.com/ubi9/httpd-24` (a mesma imagem das trilhas anteriores, normalmente já em cache).
- Recomendado: baseline de quota em `ac04-pods` ([ORI-012](../00-orientacao/exercicios/ORI-012.md)). O POD-012 mostra como ela muda a classe de QoS.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [POD-001](exercicios/POD-001.md) | Anatomia de um Pod sem criar nada | MUTAÇÃO LOCAL (projeto) |
| [POD-002](exercicios/POD-002.md) | Criar um Pod e acompanhar seu ciclo de vida | MUTAÇÃO LOCAL |
| [POD-003](exercicios/POD-003.md) | Pods que terminam: restartPolicy e códigos de saída | MUTAÇÃO LOCAL |
| [POD-004](exercicios/POD-004.md) | Logs: atuais, contínuos, recentes e com horário | LEITURA |
| [POD-005](exercicios/POD-005.md) | Vários contêineres e init containers | MUTAÇÃO LOCAL |
| [POD-006](exercicios/POD-006.md) | exec: comandos pontuais dentro do contêiner | LEITURA |
| [POD-007](exercicios/POD-007.md) | Shell interativo: exec -it e rsh | LEITURA |
| [POD-008](exercicios/POD-008.md) | Copiar arquivos: oc cp nos dois sentidos | MUTAÇÃO LOCAL |
| [POD-009](exercicios/POD-009.md) | port-forward: acessar um pod ou Service pela ocp-admin | LEITURA |
| [POD-010](exercicios/POD-010.md) | attach, logs e exec: três formas de "olhar" um contêiner | MUTAÇÃO LOCAL |
| [POD-011](exercicios/POD-011.md) | Comando, argumentos e variáveis de ambiente | MUTAÇÃO LOCAL |
| [POD-012](exercicios/POD-012.md) | Requests, limits e classes de QoS | MUTAÇÃO LOCAL |
| [POD-013](exercicios/POD-013.md) | oc debug: uma cópia do pod para investigar | MUTAÇÃO LOCAL |
| [POD-014](exercicios/POD-014.md) | Do pod ao contêiner: IDs, imagem e nó | LEITURA |
| [POD-015](exercicios/POD-015.md) | Circuito de pods e encerramento da trilha | MUTAÇÃO LOCAL |

Todos com perfil `developer`. Gabaritos: [`solucoes/04-pods/`](../../solucoes/04-pods/). Fichas:
[`oc-run`](../../catalogo/fichas/oc-run.md), [`oc-logs`](../../catalogo/fichas/oc-logs.md),
[`oc-exec-rsh`](../../catalogo/fichas/oc-exec-rsh.md), [`oc-port-forward`](../../catalogo/fichas/oc-port-forward.md).
Cenários: [TS-013](../../cenarios/troubleshooting/TS-013.md) (CrashLoopBackOff),
[TS-014](../../cenarios/troubleshooting/TS-014.md) (Pending), [TS-015](../../cenarios/troubleshooting/TS-015.md) (OOMKilled).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 04
scripts/academy show POD-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac04-pods` | POD-001 | POD-015 |
| pod `ac04-web` | POD-002 | POD-015 |
| pod `ac04-duplo` (3 contêineres) | POD-005 | POD-015 |
| pods de teste (`ac04-n0`, `ac04-log`, `ac04-eco`, `ac04-qos-*`...) | POD-003 a POD-014 | no próprio exercício |
| Service `ac04-web` | POD-009 | POD-009 |
| túneis `oc port-forward` | POD-009 | POD-009 (confira com `pgrep -af 'oc port-forward'`) |
| arquivos `/tmp/ac04-*` na `ocp-admin` | POD-008, POD-009 | POD-015 |

Nenhum exercício usa `oc debug node/`, `crictl` com escrita ou acesso ao nó sem autorização.
