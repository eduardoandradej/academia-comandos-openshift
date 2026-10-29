# SIM-01 — Simulado de administração do cluster

> **Duração:** 3 horas · **Tarefas:** 17 · **Perfis:** `developer` e `admin` · **Status:** proposto (revisado
> estaticamente; ainda não executado contra o cluster pelo autor)
>
> Enunciado original da Academia, sem relação com questões de exame. Autoavaliação, sem nota:
> `scripts/simulado/sim-01-verifica.sh` confere cada requisito. Gabarito (só depois):
> [`solucoes/simulados/sim-01.md`](../../solucoes/simulados/sim-01.md).

## Regras

1. Cronômetro de **3 horas**, começando depois da preparação.
2. Consulta permitida: documentação do OpenShift, `--help`, `oc explain`. Não consulte a Academia nem o gabarito.
3. Valores secretos (senhas, código do cofre) são **escolhidos por você e digitados no prompt**: nunca em linha de
   comando, nunca em arquivo do repositório.
4. Tarefas **VERMELHAS** mexem no cluster inteiro: faça o backup indicado, confira o perfil `ac-recovery` antes e
   desfaça no fim com `scripts/simulado/sim-01-limpa.sh` (que imprime o roteiro manual).
5. "Nada adicionado ou removido" significa: corrija o objeto existente, sem apagar e recriar e sem tirar campos que
   já existiam.

## Ambiente

| Item | Valor |
|---|---|
| API | `https://api.ocp.example.lab:6443` |
| Domínio das Routes | `*.apps.ocp.example.lab` |
| Terminal | `student@ocp-admin`, na raiz do repositório |
| Perfis | `source scripts/perfis.sh`, depois `ac-dev` (developer) ou `ac-admin` (admin) |
| Imagens | `registry.access.redhat.com/ubi9/httpd-24`, `registry.access.redhat.com/ubi9/ubi-minimal` |

## Preparação (fora do cronômetro)

```bash
source scripts/perfis.sh && ac-dev
scripts/preflight.sh                                  # sem FALHA; memória do nó abaixo de 85%
scripts/simulado/sim-01-prepara.sh                    # mostra o plano
scripts/simulado/sim-01-prepara.sh --execute          # cria 8 projetos ac-sim-* com aplicações
mkdir -p ~/sim-01 && chmod 700 ~/sim-01               # seus arquivos de trabalho (fora do repositório)
```

**REQUER PREPARAÇÃO:**

- tarefa 01: comando `htpasswd` (pacote `httpd-tools`) e o perfil `ac-recovery` testado ([docs/12](../../docs/12-preparacao-usuarios.md));
- tarefa 08: cliente `helm` ([docs/11](../../docs/11-preparacao-helm.md)) e, em outro terminal,
  `scripts/simulado/sim-01-helm-repo.sh --servir` (repositório local em `http://127.0.0.1:8879`);
- tarefa 15: catálogo `redhat-operators` disponível (só leitura e dry-run, salvo autorização explícita sua).

## Ordem sugerida

As tarefas 02 e 14 mudam o comportamento de **todos** os projetos novos. Faça-as no fim, nesta ordem:

Sequência: `03 → 04 → 05 → 06 → 07 → 08 → 09 → 10 → 11 → 12 → 13 → 16 → 17 → 01 → 14 → 02 → 15`.

---

## Tarefa 01 — Provedor de identidade HTPasswd adicional · VERMELHO · admin

Configure o cluster para aceitar um **segundo** provedor HTPasswd:

- nome do provedor: `academia-simulado`;
- Secret com o arquivo de senhas: `academia-simulado-htpasswd`, em `openshift-config`;
- usuários `sim-ana`, `sim-bruno`, `sim-carla`, `sim-davi` e `sim-elisa`, com senhas escolhidas por você;
- o provedor existente `homelab-users` continua funcionando;
- cada usuário consegue entrar pelo menos uma vez (console ou CLI).

## Tarefa 02 — Permissões de cluster · VERMELHO · admin

- `sim-davi` pode executar qualquer tarefa de administração do cluster;
- `sim-elisa` pode criar projetos, mas não administra o cluster;
- `sim-ana` **não** pode criar projetos;
- remoção do `kubeadmin`: **não execute**. Escreva em `~/sim-01/plano-kubeadmin.md` o que você conferiria antes, o
  comando que usaria e por que ele é irreversível.

## Tarefa 03 — Projetos e permissões de projeto · developer

- existem os projetos `ac-sim-norte`, `ac-sim-sul`, `ac-sim-leste`, `ac-sim-oeste` e `ac-sim-centro`;
- `sim-ana` administra `ac-sim-norte` e `ac-sim-leste`;
- `sim-elisa` consegue ver `ac-sim-centro`, mas não alterar nem apagar nada nele.

## Tarefa 04 — Grupos · admin

- grupo `sim-coordenacao` com `sim-ana`; grupo `sim-operacao` com `sim-bruno` e `sim-carla`;
- membros de `sim-coordenacao` podem editar `ac-sim-norte`;
- membros de `sim-operacao` podem apenas ver `ac-sim-norte`.

## Tarefa 05 — Limites em `ac-sim-sul` · admin

Crie o LimitRange `sim-limites`:

- por **pod**: memória entre 8Mi e 384Mi; CPU entre 10m e 400m;
- por **contêiner**: memória entre 8Mi e 384Mi, com requisição padrão de 64Mi; CPU entre 10m e 400m, com
  requisição padrão de 50m.

## Tarefa 06 — Route segura · developer

A aplicação `vitrine` (projeto `ac-sim-vitrine`) deve:

- ser publicada por uma Route chamada `vitrine`, com tráfego **criptografado entre cliente e router** e **sem
  criptografia entre router e Service**;
- usar um certificado assinado por uma CA sua, com assunto
  `/C=BR/ST=SP/L=Campinas/O=Academia/OU=Simulado/CN=vitrine-segura.apps.ocp.example.lab`;
- responder **somente** em `vitrine-segura.apps.ocp.example.lab`.

Ferramenta fornecida: `scripts/simulado/sim-01-certificado.sh` (gera a CA e o certificado em `~/sim-01/certs`).

## Tarefa 07 — Dados de aplicação por ConfigMap · developer

No projeto `ac-sim-painel`, a aplicação `painel` mostra o conteúdo da variável `SAUDACAO`. Faça a página exibir
**`Bem-vindo ao simulado da Academia`**, com o valor guardado na chave `SAUDACAO` do ConfigMap `painel-textos`.

## Tarefa 08 — Aplicação por chart Helm · developer · REQUER PREPARAÇÃO

- adicione o repositório `http://127.0.0.1:8879` com o nome `academia-local`;
- instale o chart `ac14-loja` desse repositório como release `loja-sim`, no projeto `ac-sim-pacotes`;
- a página da loja deve dizer `pacote do simulado`.

## Tarefa 09 — Segredo para a aplicação · developer

No projeto `ac-sim-cofre`:

- crie o Secret `cofre-chave` com a chave `codigo-acesso` (valor escolhido por você, digitado no prompt);
- a aplicação `cofre` recebe esse valor na variável de ambiente `CODIGO_ACESSO`;
- a página deixa de mostrar `acesso negado`.

## Tarefa 10 — ServiceAccount privilegiada na medida · admin

No projeto `ac-sim-raiz`, crie a ServiceAccount `executor-raiz` e permita que pods que a usam rodem **com qualquer
UID**, inclusive root. Nenhuma outra ServiceAccount ganha esse direito.

## Tarefa 11 — A aplicação que não sobe · developer

A aplicação `raiz` (projeto `ac-sim-raiz`) não tem nenhum pod. Faça-a rodar e produzir saída **usando a
ServiceAccount `executor-raiz`**, sem adicionar nem remover nada da configuração existente.

## Tarefa 12 — A aplicação que reinicia · developer

A aplicação `calculo` (projeto `ac-sim-memoria`) nunca conclui o cálculo. Faça-a produzir a saída
`cálculo concluído` e ficar pronta, sem adicionar nem remover componentes.

## Tarefa 13 — Política de rede · developer + admin

- crie, em `ac-sim-dados`, a NetworkPolicy `banco-acesso-auditoria`, aplicada aos pods com `papel=banco`;
- só podem conectar pods com o rótulo `acesso=leitura-banco` **que estejam** em projetos com o rótulo
  `equipe=auditoria`, e somente na porta `8080/TCP`;
- rotule o projeto `ac-sim-cliente` com `equipe=auditoria` (perfil admin);
- confira pelos logs: `consulta` (em `ac-sim-cliente`) conecta; `curioso` (em `ac-sim-intruso`) não.

## Tarefa 14 — Modelo de projeto · VERMELHO · admin

Configure o cluster para que **todo projeto novo** receba um LimitRange chamado `<projeto>-limites`, com memória
por contêiner entre 128Mi e 384Mi, limite padrão de 256Mi e requisição padrão de 128Mi.

- o modelo se chama `academia-modelo-projeto`;
- prove criando o projeto `ac-sim-modelo`;
- desfaça assim que terminar o simulado (o modelo afeta todos os projetos novos).

## Tarefa 15 — Operador · VERMELHO · admin

Prepare a instalação do **cert-manager Operator for Red Hat OpenShift**:

- namespace `cert-manager-operator`, com o monitoramento do cluster habilitado;
- aprovação de atualizações **manual**;
- escreva o plano em `~/sim-01/plano-operador.md` (recursos que serão criados, consumo esperado, como desinstalar)
  e valide o que for possível com `--dry-run=server`;
- instalar de fato só com a sua autorização explícita, sabendo que o SNO tem recursos limitados.

## Tarefa 16 — Rotina agendada · developer

No projeto `ac-sim-rotina`, crie o CronJob `fechamento-mensal`:

- imagem `registry.access.redhat.com/ubi9/ubi-minimal:latest`, imprimindo a data;
- roda à **01:20 do dia 10 de cada mês**;
- guarda 4 execuções com sucesso e 1 com falha;
- usa a ServiceAccount `operador-rotina`;
- fica **suspenso** (regra da Academia); prove com um Job manual criado a partir dele.

## Tarefa 17 — Quota de projeto · admin

No projeto `ac-sim-centro`, crie a ResourceQuota `sim-cota`:

| Recurso | Máximo |
|---|---|
| soma das requisições de CPU | 500m |
| soma das requisições de memória | 512Mi |
| pods | 5 |
| Services | 4 |
| ReplicationControllers | 2 |
| Secrets | 12 |

---

## Autoavaliação

```bash
source scripts/perfis.sh && ac-admin
scripts/simulado/sim-01-verifica.sh                 # todas as tarefas
scripts/simulado/sim-01-verifica.sh --tarefa 13     # só uma
```

Anote o tempo total e as tarefas com `FALHA`. Revise as trilhas correspondentes (tabela no gabarito) em D+1, D+7 e
D+30 e refaça o simulado.

## Encerramento

```bash
scripts/simulado/sim-01-limpa.sh                    # mostra o que sairia + o roteiro manual de cluster
scripts/simulado/sim-01-limpa.sh --execute          # apaga os projetos ac-sim-* (pede "sim-01")
# depois, como admin, rode à mão os blocos de reversão das tarefas VERMELHAS que você fez
```
