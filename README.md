# Academia de Comandos: OpenShift

[![validate-docs](https://github.com/eduardoandradej/academia-comandos-openshift/actions/workflows/validate-docs.yml/badge.svg)](https://github.com/eduardoandradej/academia-comandos-openshift/actions/workflows/validate-docs.yml)
![OpenShift](https://img.shields.io/badge/OpenShift-4.22%20SNO-red)
![Licença](https://img.shields.io/badge/licen%C3%A7a-Apache--2.0-blue)

Prática intensiva de `oc`, `kubectl` e administração do OpenShift 4.22: comandos explicados, exercícios
progressivos, desafios, troubleshooting e repetição deliberada em um HomeLab Single Node OpenShift.

## Guia direto: comandos e explicação em uma página

Quer só os comandos, prontos para ler e aplicar? Abra o **[guia direto](guia/README.md)**: uma página por trilha, com
cada bloco de comandos seguido de uma tabela curta explicando o que cada um faz.

| Página | Assunto |
|---|---|
| [00 — Orientação e segurança](guia/00-orientacao.md) | onde estou, quem sou, perfis, saúde do cluster, projeto de treino |
| [01 — Navegação e CLI](guia/01-cli.md) | versões, ajuda, login/logout, kubeconfig, projetos, contextos |
| [02 — Leitura e inspeção](guia/02-consultas.md) | `get`, `describe`, `explain`, filtros, JSONPath, jq, eventos |
| [03 — Projetos e metadados](guia/03-projetos.md) | rótulos, anotações, seletores, donos, finalizers |
| [04 — Pods e contêineres](guia/04-pods.md) | criar pods, logs, exec, rsh, cp, port-forward, debug, QoS, erros comuns |
| [05 — Deployments e workloads](guia/05-deployments.md) | criar, escalar, rollout, undo, restart, set, estratégias, Jobs, CronJobs, DaemonSet |
| [06 — Services e DNS](guia/06-servicos.md) | criar Services, portas, endpoints, DNS interno, azul/verde, headless, diagnóstico |
| [07 — Routes e Ingress](guia/07-rotas.md) | Routes HTTP, hostname, caminhos, HTTPS edge/passthrough, pesos, Ingress, diagnóstico |
| [08 — ConfigMaps e Secrets](guia/08-config.md) | criar ConfigMaps e Secrets, variáveis, arquivos, subPath, TLS, pull secret, imutáveis, extract, quem lê Secrets |
| [09 — Storage](guia/09-storage.md) | volumes, emptyDir, efêmero e despejo, PVC, modos de acesso, expansão, StatefulSet (PVC: REQUER PREPARAÇÃO) |
| [10 — Imagens e registries](guia/10-imagens.md) | referência e digest, `oc image info`, pull policy, ImageStreams, `oc tag`, image-lookup, gatilhos, registry interno |
| [11 — Resiliência](guia/11-resiliencia.md) | requests/limits, `oc adm top`, readiness/liveness/startup, autocura, preStop, rollout sem queda, HPA, PDB |
| [12 — Manifestos declarativos](guia/12-declarativo.md) | gerar, validar, `apply`, `diff`, merge de três vias, server-side apply, `replace`, `patch`, prune |
| [13 — Kustomize e Templates](guia/13-kustomize.md) | base e overlays, geradores com hash, images/replicas, patches, `oc process`, `new-app --template` |

O restante do repositório (trilhas com desafios, falhas provocadas, gabaritos e scripts) é para a prática aprofundada.

> **Projeto de aprendizagem independente.** Não é material oficial, não reproduz roteiros, scripts `lab` nem a grade
> da Red Hat e não substitui cursos, infraestrutura, documentação ou certificação. OpenShift e Red Hat são marcas da
> Red Hat, Inc.

## O que é (e o que não é)

| Repositório | Foco |
|---|---|
| [openshift-do180-4.22-estudos](https://github.com/eduardoandradej/openshift-do180-4.22-estudos) | estudo por **capítulo** do DO180 |
| [openshift-do280-4.22-estudos](https://github.com/eduardoandradej/openshift-do280-4.22-estudos) | estudo por **capítulo** do DO280 |
| **Academia de Comandos** (este) | **domínio operacional** por família de comando: executar, repetir, diagnosticar e limpar até virar memória muscular |

Cada exercício tem: objetivo verificável, contexto e perfil, pré-flight, conceito, comandos guiados com cada flag
comentada, repetições, **desafio sem pista**, **diagnóstico controlado**, validação, **limpeza segura**, gabarito
**separado** e ficha de revisão espaçada.

## Estado atual (honesto)

| Item | Atual | Meta |
|---|---:|---:|
| Trilhas completas | 14 (00 a 13) | 21 |
| Microexercícios | 210 | 300+ |
| Cenários de troubleshooting | 42 | 40+ ✔ |
| Comandos e formas catalogados | 235 | 200+ |
| Fichas de comando | 35 | — |

Status dos exercícios: **proposto** — escritos e revisados estaticamente (Markdown, YAML, shell, links, testes
offline), mas **ainda não executados contra o cluster** pelo autor. A validação acontece quando você os executa.

## Arquitetura do HomeLab

```mermaid
flowchart LR
  ADM[ocp-admin<br/>RHEL 9.8 - student<br/>oc, kubectl, jq] -->|API 6443| SNO[ocp-sno<br/>OCP 4.22.0 SNO<br/>6 vCPU - 20 GiB]
  ADM -->|DNS| DNS[dnsmasq-ocp<br/>192.168.10.25]
  WIN[Windows] -->|Console 443| SNO
  subgraph KVM[kvm-server - Rocky 9.4 - SSD 240 GB]
    ADM
    SNO
    DNS
  end
```

Detalhes e limites em [docs/01-topologia-homelab.md](docs/01-topologia-homelab.md).

## Início rápido

```bash
# na ocp-admin, como student
git clone https://github.com/eduardoandradej/academia-comandos-openshift.git ~/academia-comandos-openshift
cd ~/academia-comandos-openshift
scripts/academy doctor          # verificação SOMENTE LEITURA
scripts/academy list            # exercícios e cenários
scripts/academy show ORI-001    # enunciado (sem gabarito)
```

Comece pela [Trilha 00](trilhas/00-orientacao/README.md). O **ORI-004** cria perfis `developer` e `admin` em
kubeconfigs próprios — o kubeconfig do instalador (`system:admin`) fica reservado para recuperação.

## Trilhas

| ID | Trilha | Status |
|---|---|---|
| 00 | [Orientação e segurança](trilhas/00-orientacao/README.md) | disponível |
| 01 | [Navegação e CLI](trilhas/01-cli/README.md) | disponível |
| 02 | [Leitura e inspeção](trilhas/02-consultas/README.md) | disponível |
| 03 | [Projetos e metadados](trilhas/03-projetos/README.md) | disponível |
| 04 | [Pods e contêineres](trilhas/04-pods/README.md) | disponível |
| 05 | [Deployments e workloads](trilhas/05-deployments/README.md) | disponível |
| 06 | [Services e DNS](trilhas/06-servicos/README.md) | disponível |
| 07 | [Routes e Ingress](trilhas/07-rotas/README.md) | disponível |
| 08 | [ConfigMaps e Secrets](trilhas/08-config/README.md) | disponível |
| 09 | [Storage](trilhas/09-storage/README.md) | disponível (PV/PVC: REQUER PREPARAÇÃO) |
| 10 | [Imagens e registries](trilhas/10-imagens/README.md) | disponível |
| 11 | [Resiliência](trilhas/11-resiliencia/README.md) | disponível |
| 12 | [Manifestos declarativos](trilhas/12-declarativo/README.md) | disponível |
| 13 | [Kustomize e Templates](trilhas/13-kustomize/README.md) | disponível |
| 14–20 | [Helm, RBAC, Rede, Administração, Operadores, Troubleshooting, Desafios](trilhas/README.md) | planejadas |

## Restrições do HomeLab

- **Um único nó**: nada de drain, cordon, reboot ou upgrade pela Academia.
- **Recursos compartilhados**: quota por projeto de laboratório (500m CPU / 768 Mi de requests), no máximo 2 réplicas.
- **SSD limitado**: manter > 20 GiB livres em `/var` do `kvm-server`; nada de workloads que gravem muito.
- **Sem StorageClass, registry privado, IdM ou LoadBalancer**: exercícios dependentes são marcados **REQUER PREPARAÇÃO** ou **NÃO DISPONÍVEL NO HOME LAB ATUAL**.
- **Componentes críticos intocáveis**: nenhuma mutação em `openshift-*`, `kube-*`, OAuth, nó ou host.

## Segurança

Semáforo **VERDE / AMARELO / VERMELHO**, projetos `acNN-*`, rótulo `academy.openshift.dev/managed-by=academia` e
scripts que simulam por padrão. Veja [docs/02-preflight-e-seguranca.md](docs/02-preflight-e-seguranca.md) e
[SECURITY.md](SECURITY.md). Nenhum kubeconfig, token, pull secret ou senha real deve entrar neste repositório.

## Modos de prática

Repetição 5× / 10× / 20×, flash, reverso, comparação, incidente, operador e revisão espaçada (D+1, D+3, D+7, D+14,
D+30). Veja [docs/05-metodologia-repeticao.md](docs/05-metodologia-repeticao.md).

## Mapa do repositório

| Caminho | Conteúdo |
|---|---|
| [`guia/`](guia/README.md) | **comandos e explicação, uma página por trilha** |
| [`docs/`](docs/00-iniciar-aqui.md) | topologia, segurança, identidades, diferenças da sala oficial, metodologia, roteiros DO180/DO280, troubleshooting, backup, preparação de storage |
| [`catalogo/`](catalogo/indice-comandos.md) | índice de comandos, famílias e comparações, erros frequentes, matriz de competências, fichas |
| [`trilhas/`](trilhas/README.md) | exercícios por trilha |
| [`cenarios/`](cenarios/troubleshooting/README.md) | cenários de troubleshooting |
| [`solucoes/`](solucoes/README.md) | gabaritos (separados de propósito) |
| [`manifests/`](manifests/README.md) | baseline de quota e alvos de observação |
| [`scripts/`](scripts/README.md) | `academy`, preflight, status, safe-cleanup, perfis |
| [`templates/`](templates/exercicio.md) | modelos de exercício, gabarito, ficha e revisão |
| [`progresso/`](progresso/README.md) | modelo de revisão (preencha fora do repositório) |
| [`tests/`](tests/run-tests.sh) | testes offline dos scripts com `oc` simulado |

## Contribuir

Veja [CONTRIBUTING.md](CONTRIBUTING.md). Licença: [Apache-2.0](LICENSE) — aplica-se apenas ao conteúdo original deste repositório.
