# Trilha 06 — Services e DNS

> **Status:** disponível · 15 microexercícios · proposto (revisado estaticamente; ainda não executado contra o cluster pelo autor)

Como os pods se encontram: Services (ClusterIP, headless, ExternalName), portas e portas nomeadas, EndpointSlices,
DNS interno e `search`, troca azul/verde por seletor, balanceamento, afinidade de sessão, variáveis de Service e um
roteiro de diagnóstico de 7 passos.

> Prefere só os comandos com a explicação? Veja o [guia direto 06](../../guia/06-servicos.md).

## Pré-requisitos

- Trilhas 00–05.
- **REQUER PREPARAÇÃO:** pull de `registry.access.redhat.com/ubi9/httpd-24` (normalmente já em cache).
- O SVC-001 implanta `manifests/apps-exemplo/servicos-azul-verde.yaml` (backends `web-azul` e `web-verde`, cada um com
  uma página de uma linha) e um pod cliente. Todos os testes HTTP são feitos **de dentro** do cluster: a `ocp-admin` não alcança ClusterIPs.
- Recomendado: baseline de quota ([ORI-012](../00-orientacao/exercicios/ORI-012.md)) — o SVC-013 mostra a recusa de NodePort/LoadBalancer.

## Exercícios

| ID | Título | Impacto |
|---|---|---|
| [SVC-001](exercicios/SVC-001.md) | Por que Services existem: IPs de pod mudam | MUTAÇÃO LOCAL |
| [SVC-002](exercicios/SVC-002.md) | Anatomia de um Service: port, targetPort e portas nomeadas | MUTAÇÃO LOCAL |
| [SVC-003](exercicios/SVC-003.md) | EndpointSlices: quem está por trás do Service | MUTAÇÃO LOCAL |
| [SVC-004](exercicios/SVC-004.md) | Testar um Service de dentro do cluster | LEITURA |
| [SVC-005](exercicios/SVC-005.md) | DNS interno: nomes curtos, namespaces e FQDN | LEITURA |
| [SVC-006](exercicios/SVC-006.md) | Seletores e troca azul/verde | MUTAÇÃO LOCAL |
| [SVC-007](exercicios/SVC-007.md) | Vários backends: balanceamento entre pods | LEITURA |
| [SVC-008](exercicios/SVC-008.md) | Headless Service: DNS que devolve os pods | MUTAÇÃO LOCAL |
| [SVC-009](exercicios/SVC-009.md) | Várias portas em um Service | MUTAÇÃO LOCAL |
| [SVC-010](exercicios/SVC-010.md) | Variáveis de ambiente de Services | MUTAÇÃO LOCAL |
| [SVC-011](exercicios/SVC-011.md) | ExternalName: um apelido DNS | MUTAÇÃO LOCAL |
| [SVC-012](exercicios/SVC-012.md) | Afinidade de sessão | MUTAÇÃO LOCAL |
| [SVC-013](exercicios/SVC-013.md) | NodePort e LoadBalancer no SNO (conceitual) | LEITURA |
| [SVC-014](exercicios/SVC-014.md) | Roteiro de diagnóstico de Service | MUTAÇÃO LOCAL |
| [SVC-015](exercicios/SVC-015.md) | Circuito de Services e encerramento da trilha | MUTAÇÃO LOCAL |

Perfil `developer`. Gabaritos: [`solucoes/06-servicos/`](../../solucoes/06-servicos/). Ficha:
[`oc-expose-service`](../../catalogo/fichas/oc-expose-service.md). Cenários: [TS-019](../../cenarios/troubleshooting/TS-019.md)
(targetPort errado), [TS-020](../../cenarios/troubleshooting/TS-020.md) (DNS entre projetos),
[TS-021](../../cenarios/troubleshooting/TS-021.md) (readiness falhando).

## Como começar

```bash
cd ~/academia-comandos-openshift
source scripts/perfis.sh && ac-dev
scripts/academy list --trilha 06
scripts/academy show SVC-001
```

## Recursos criados e limpeza

| Recurso | Criado em | Removido em |
|---|---|---|
| projeto `ac06-servicos` | SVC-001 | SVC-015 |
| Deployments `web-azul`, `web-verde` (1 réplica cada) e pod `ac06-cliente` | SVC-001 | SVC-015 |
| Services de teste (`loja`, `loja-80`, `loja-headless`...) | SVC-001 a SVC-014 | no próprio exercício / SVC-015 |
| projetos `ac06-outro`, `ac06-consumidor` | SVC-005, TS-020 | no próprio exercício/cenário |

Nenhum exercício cria NodePort, LoadBalancer ou altera o DNS do cluster.
