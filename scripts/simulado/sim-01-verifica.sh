#!/usr/bin/env bash
# sim-01-verifica.sh — autoavaliação do Simulado 01: uma linha OK/FALHA por requisito. Não dá nota.
#
# Executar em: student@ocp-admin. Perfil admin recomendado (ac-admin): várias tarefas são de cluster.
#              Com developer, as verificações sem permissão aparecem como PULADO.
# Impacto:     LEITURA. Nenhuma chamada altera o cluster (o HTPasswd é lido só para listar nomes,
#              em diretório temporário apagado em seguida).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/scripts/lib/common.sh"

TAREFA=""
usage() {
  cat <<USO
Uso: sim-01-verifica.sh [--tarefa N]

Confere os requisitos das 17 tarefas (ou só da tarefa N) e mostra OK, FALHA ou PULADO.
USO
}
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tarefa) TAREFA="${2:-}"; [[ "$TAREFA" =~ ^[0-9]+$ ]] || { usage >&2; exit 2; }; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

ac_have oc || ac_die "comando oc não encontrado"
oc whoami >/dev/null 2>&1 || ac_die "sem sessão no cluster"

quero() { [[ -z "$TAREFA" || "$TAREFA" == "$1" ]]; }
# confere DESCRIÇÃO COMANDO... — OK se o comando terminar com sucesso
confere() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then ac_ok "$d"; else ac_fail "$d"; fi; }
igual() { [[ "$(eval "$2" 2>/dev/null)" == "$3" ]]; }
pode() { [[ "$(oc auth can-i "$@" 2>/dev/null)" == yes ]]; }
admin() { [[ "$(oc auth can-i get oauths.config.openshift.io 2>/dev/null)" == yes ]]; }
G="--as-group=system:authenticated --as-group=system:authenticated:oauth"
USUARIOS="sim-ana sim-bruno sim-carla sim-davi sim-elisa"

if quero 1; then
  ac_title "Tarefa 01 — provedor HTPasswd adicional"
  if admin; then
    idps="$(oc get oauth cluster -o jsonpath='{range .spec.identityProviders[*]}{.name}={.htpasswd.fileData.name}{"\n"}{end}')"
    confere "provedor academia-simulado usa o Secret academia-simulado-htpasswd" grep -qx 'academia-simulado=academia-simulado-htpasswd' <<<"$idps"
    confere "provedor original homelab-users continua presente" grep -q '^homelab-users=' <<<"$idps"
    d="$(mktemp -d)"
    if oc extract secret/academia-simulado-htpasswd -n openshift-config --keys=htpasswd --to="$d" >/dev/null 2>&1; then
      for u in $USUARIOS; do confere "usuário $u no HTPasswd" grep -q "^$u:" "$d/htpasswd"; done
    else
      ac_fail "Secret academia-simulado-htpasswd (chave htpasswd) em openshift-config"
    fi
    rm -rf "$d"
    for u in $USUARIOS; do
      if oc get user "$u" >/dev/null 2>&1; then ac_ok "$u já fez login"; else ac_warn "$u ainda não fez login (faça o teste de login)"; fi
    done
  else
    ac_skip "tarefa 01 exige perfil admin"
  fi
fi

if quero 2; then
  ac_title "Tarefa 02 — permissões de cluster"
  if admin; then
    # shellcheck disable=SC2086
    confere "sim-davi administra o cluster" pode '*' '*' --all-namespaces --as=sim-davi $G
    # shellcheck disable=SC2086
    confere "sim-elisa cria projetos" pode create projectrequests.project.openshift.io --as=sim-elisa $G
    # shellcheck disable=SC2086
    confere "sim-elisa não administra o cluster" bash -c "! oc auth can-i get nodes --as=sim-elisa $G | grep -qx yes"
    # shellcheck disable=SC2086
    confere "sim-ana não cria projetos" bash -c "! oc auth can-i create projectrequests.project.openshift.io --as=sim-ana $G | grep -qx yes"
    confere "plano de remoção do kubeadmin escrito (~/sim-01/plano-kubeadmin.md)" test -s "$HOME/sim-01/plano-kubeadmin.md"
    if oc get secret kubeadmin -n kube-system >/dev/null 2>&1; then
      ac_info "kubeadmin continua presente (esperado: a Academia não o remove)"
    else
      ac_warn "o Secret kubeadmin não existe mais — confira se isso foi decisão sua, fora do simulado"
    fi
  else
    ac_skip "tarefa 02 exige perfil admin"
  fi
fi

if quero 3; then
  ac_title "Tarefa 03 — projetos e permissões de projeto"
  for p in ac-sim-norte ac-sim-sul ac-sim-leste ac-sim-oeste ac-sim-centro; do confere "projeto $p existe" oc get project "$p"; done
  if admin; then
    for p in ac-sim-norte ac-sim-leste; do
      # shellcheck disable=SC2086
      confere "sim-ana administra $p" pode create rolebindings -n "$p" --as=sim-ana $G
    done
    # shellcheck disable=SC2086
    confere "sim-elisa vê ac-sim-centro" pode get pods -n ac-sim-centro --as=sim-elisa $G
    # shellcheck disable=SC2086
    confere "sim-elisa não altera ac-sim-centro" bash -c "! oc auth can-i create deployments.apps -n ac-sim-centro --as=sim-elisa $G | grep -qx yes"
    # shellcheck disable=SC2086
    confere "sim-elisa não apaga ac-sim-centro" bash -c "! oc auth can-i delete projects.project.openshift.io/ac-sim-centro --as=sim-elisa $G | grep -qx yes"
  else
    ac_skip "permissões de outros usuários exigem perfil admin (impersonação)"
  fi
fi

if quero 4; then
  ac_title "Tarefa 04 — grupos"
  if admin; then
    confere "sim-ana no grupo sim-coordenacao" bash -c "oc get group sim-coordenacao -o jsonpath='{.users}' | grep -q '\"sim-ana\"'"
    confere "sim-bruno no grupo sim-operacao" bash -c "oc get group sim-operacao -o jsonpath='{.users}' | grep -q '\"sim-bruno\"'"
    confere "sim-carla no grupo sim-operacao" bash -c "oc get group sim-operacao -o jsonpath='{.users}' | grep -q '\"sim-carla\"'"
    confere "sim-coordenacao edita ac-sim-norte" pode create deployments.apps -n ac-sim-norte --as=qualquer --as-group=sim-coordenacao --as-group=system:authenticated
    confere "sim-operacao vê ac-sim-norte" pode get pods -n ac-sim-norte --as=qualquer --as-group=sim-operacao --as-group=system:authenticated
    confere "sim-operacao não edita ac-sim-norte" bash -c "! oc auth can-i create deployments.apps -n ac-sim-norte --as=qualquer --as-group=sim-operacao --as-group=system:authenticated | grep -qx yes"
  else
    ac_skip "tarefa 04 exige perfil admin"
  fi
fi

if quero 5; then
  ac_title "Tarefa 05 — LimitRange em ac-sim-sul"
  lr="$(oc get limitrange sim-limites -n ac-sim-sul -o json 2>/dev/null || true)"
  if [[ -n "$lr" ]]; then
    j() { jq -r "$1" <<<"$lr"; }
    confere "Pod: memória 8Mi–384Mi"   igual x "j '.spec.limits[] | select(.type==\"Pod\") | \"\(.min.memory)-\(.max.memory)\"'" "8Mi-384Mi"
    confere "Pod: CPU 10m–400m"        igual x "j '.spec.limits[] | select(.type==\"Pod\") | \"\(.min.cpu)-\(.max.cpu)\"'" "10m-400m"
    confere "Container: memória 8Mi–384Mi, request padrão 64Mi" igual x "j '.spec.limits[] | select(.type==\"Container\") | \"\(.min.memory)-\(.max.memory)-\(.defaultRequest.memory)\"'" "8Mi-384Mi-64Mi"
    confere "Container: CPU 10m–400m, request padrão 50m" igual x "j '.spec.limits[] | select(.type==\"Container\") | \"\(.min.cpu)-\(.max.cpu)-\(.defaultRequest.cpu)\"'" "10m-400m-50m"
  else
    ac_fail "LimitRange sim-limites em ac-sim-sul"
  fi
fi

if quero 6; then
  ac_title "Tarefa 06 — Route segura da vitrine"
  H=vitrine-segura.apps.ocp.example.lab
  confere "Route vitrine é edge"                 igual x "oc get route vitrine -n ac-sim-vitrine -o jsonpath='{.spec.tls.termination}'" edge
  confere "Route vitrine usa o host $H"          igual x "oc get route vitrine -n ac-sim-vitrine -o jsonpath='{.spec.host}'" "$H"
  confere "certificado próprio na Route"         bash -c "oc get route vitrine -n ac-sim-vitrine -o jsonpath='{.spec.tls.certificate}' | grep -q 'BEGIN CERTIFICATE'"
  confere "só uma Route no projeto"              igual x "oc get routes -n ac-sim-vitrine --no-headers | wc -l | tr -d ' '" 1
  confere "certificado com O=Academia e CN=$H"   bash -c "echo | openssl s_client -connect $H:443 -servername $H 2>/dev/null | openssl x509 -noout -subject | grep -q 'O *= *Academia.*CN *= *$H'"
  confere "HTTPS responde a página"              bash -c "curl -sk -m 5 https://$H/ | grep -q 'vitrine do simulado'"
fi

if quero 7; then
  ac_title "Tarefa 07 — dados de aplicação (ConfigMap)"
  confere "ConfigMap painel-textos com a chave SAUDACAO" bash -c "oc get cm painel-textos -n ac-sim-painel -o jsonpath='{.data.SAUDACAO}' | grep -q ."
  confere "SAUDACAO vem do ConfigMap (configMapKeyRef ou envFrom)" bash -c "oc get deploy painel -n ac-sim-painel -o json | jq -e '.spec.template.spec.containers[0] | ([.env[]?.valueFrom.configMapKeyRef.name] + [.envFrom[]?.configMapRef.name]) | index(\"painel-textos\")'"
  confere "a página mostra a saudação"          bash -c "curl -s -m 5 http://\$(oc get route painel -n ac-sim-painel -o jsonpath='{.spec.host}')/ | grep -q 'Bem-vindo ao simulado da Academia'"
fi

if quero 8; then
  ac_title "Tarefa 08 — Helm"
  if ac_have helm; then
    confere "repositório academia-local configurado" bash -c "helm repo list -o json | jq -e '.[] | select(.name==\"academia-local\")'"
    confere "release loja-sim deployed em ac-sim-pacotes" igual x "helm status loja-sim -n ac-sim-pacotes -o json | jq -r .info.status" deployed
    confere "release veio do chart ac14-loja"     igual x "helm list -n ac-sim-pacotes -o json | jq -r '.[] | select(.name==\"loja-sim\") | .chart'" ac14-loja-0.1.0
    confere "página personalizada"                bash -c "oc get cm -n ac-sim-pacotes -l app.kubernetes.io/instance=loja-sim -o json | grep -q 'pacote do simulado'"
  else
    ac_skip "cliente helm ausente (REQUER PREPARAÇÃO: docs/11)"
  fi
fi

if quero 9; then
  ac_title "Tarefa 09 — Secret"
  confere "Secret cofre-chave com a chave codigo-acesso" bash -c "oc get secret cofre-chave -n ac-sim-cofre -o jsonpath='{.data.codigo-acesso}' | grep -q ."
  confere "CODIGO_ACESSO vem do Secret" bash -c "oc get deploy cofre -n ac-sim-cofre -o json | jq -e '.spec.template.spec.containers[0] | [.env[]? | select(.name==\"CODIGO_ACESSO\") | .valueFrom.secretKeyRef.name] | index(\"cofre-chave\")'"
  confere "a página não diz mais 'acesso negado'" bash -c "curl -s -m 5 http://\$(oc get route cofre -n ac-sim-cofre -o jsonpath='{.spec.host}')/ | grep -q 'cofre aberto'"
fi

if quero 10; then
  ac_title "Tarefa 10 — ServiceAccount com anyuid"
  confere "SA executor-raiz existe" oc get sa executor-raiz -n ac-sim-raiz
  confere "executor-raiz pode usar a SCC anyuid" pode use securitycontextconstraints.security.openshift.io/anyuid -n ac-sim-raiz --as=system:serviceaccount:ac-sim-raiz:executor-raiz
fi

if quero 11; then
  ac_title "Tarefa 11 — aplicação raiz"
  confere "raiz usa a SA executor-raiz"  igual x "oc get deploy raiz -n ac-sim-raiz -o jsonpath='{.spec.template.spec.serviceAccountName}'" executor-raiz
  confere "raiz pronta (1/1)"            igual x "oc get deploy raiz -n ac-sim-raiz -o jsonpath='{.status.readyReplicas}'" 1
  confere "saída mostra uid 0"           bash -c "oc logs deploy/raiz -n ac-sim-raiz --tail=5 | grep -q 'uid 0'"
  confere "runAsUser: 0 continua (nada removido)" igual x "oc get deploy raiz -n ac-sim-raiz -o jsonpath='{.spec.template.spec.securityContext.runAsUser}'" 0
fi

if quero 12; then
  ac_title "Tarefa 12 — aplicação calculo"
  confere "calculo pronta (1/1)"         igual x "oc get deploy calculo -n ac-sim-memoria -o jsonpath='{.status.readyReplicas}'" 1
  confere "saída 'cálculo concluído'"    bash -c "oc logs deploy/calculo -n ac-sim-memoria | grep -q 'cálculo concluído'"
  confere "mesmos componentes (1 contêiner, mesmo comando)" bash -c "oc get deploy calculo -n ac-sim-memoria -o json | jq -e '(.spec.template.spec.containers | length) == 1 and (.spec.template.spec.containers[0].args[0] | test(\"dd if=/dev/zero\"))'"
  confere "limite de memória declarado"  bash -c "oc get deploy calculo -n ac-sim-memoria -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' | grep -q ."
fi

if quero 13; then
  ac_title "Tarefa 13 — NetworkPolicy"
  np="$(oc get networkpolicy banco-acesso-auditoria -n ac-sim-dados -o json 2>/dev/null || true)"
  if [[ -n "$np" ]]; then
    confere "seleciona os pods papel=banco"  igual x "jq -r '.spec.podSelector.matchLabels.papel' <<<'$np'" banco
    confere "origem: projeto equipe=auditoria E pods acesso=leitura-banco (mesmo item)" bash -c "jq -e '.spec.ingress[].from[] | select(.namespaceSelector.matchLabels.equipe==\"auditoria\" and .podSelector.matchLabels.acesso==\"leitura-banco\")' <<<'$np'"
    confere "porta 8080/TCP"                 bash -c "jq -e '.spec.ingress[].ports[] | select(.port==8080 and (.protocol // \"TCP\")==\"TCP\")' <<<'$np'"
  else
    ac_fail "NetworkPolicy banco-acesso-auditoria em ac-sim-dados"
  fi
  if admin; then confere "projeto ac-sim-cliente rotulado equipe=auditoria" igual x "oc get namespace ac-sim-cliente -o jsonpath='{.metadata.labels.equipe}'" auditoria; fi
  confere "consulta (ac-sim-cliente) conecta"   bash -c "oc logs deploy/consulta -n ac-sim-cliente --tail=1 | grep -q 'banco: conectado'"
  confere "curioso (ac-sim-intruso) bloqueado"  bash -c "oc logs deploy/curioso -n ac-sim-intruso --tail=1 | grep -q 'banco: sem resposta'"
fi

if quero 14; then
  ac_title "Tarefa 14 — modelo de projeto"
  if admin; then
    confere "Template academia-modelo-projeto em openshift-config" oc get template academia-modelo-projeto -n openshift-config
    confere "projects.config aponta para o modelo" igual x "oc get project.config.openshift.io cluster -o jsonpath='{.spec.projectRequestTemplate.name}'" academia-modelo-projeto
    if oc get project ac-sim-modelo >/dev/null 2>&1; then
      lr="$(oc get limitrange ac-sim-modelo-limites -n ac-sim-modelo -o json 2>/dev/null || true)"
      confere "projeto de teste tem o LimitRange ac-sim-modelo-limites" test -n "$lr"
      confere "Container: memória 128Mi–384Mi, padrão 256Mi, request padrão 128Mi" bash -c "jq -e '.spec.limits[] | select(.type==\"Container\" and .min.memory==\"128Mi\" and .max.memory==\"384Mi\" and .default.memory==\"256Mi\" and .defaultRequest.memory==\"128Mi\")' <<<'$lr'"
    else
      ac_fail "projeto de teste ac-sim-modelo (crie-o depois de configurar o modelo)"
    fi
  else
    ac_skip "tarefa 14 exige perfil admin"
  fi
fi

if quero 15; then
  ac_title "Tarefa 15 — operador"
  confere "plano de instalação escrito (~/sim-01/plano-operador.md)" test -s "$HOME/sim-01/plano-operador.md"
  if admin && oc get namespace cert-manager-operator >/dev/null 2>&1; then
    confere "Subscription com aprovação Manual" igual x "oc get subscriptions.operators.coreos.com -n cert-manager-operator -o jsonpath='{.items[0].spec.installPlanApproval}'" Manual
    confere "monitoramento habilitado no namespace" igual x "oc get namespace cert-manager-operator -o jsonpath='{.metadata.labels.openshift\\.io/cluster-monitoring}'" true
    confere "CSV Succeeded" bash -c "oc get csv -n cert-manager-operator -o jsonpath='{.items[*].status.phase}' | grep -q Succeeded"
  else
    ac_skip "operador não instalado (modo seguro: só plano e dry-run) ou sem perfil admin"
  fi
fi

if quero 16; then
  ac_title "Tarefa 16 — CronJob"
  cj="$(oc get cronjob fechamento-mensal -n ac-sim-rotina -o json 2>/dev/null || true)"
  if [[ -n "$cj" ]]; then
    confere "agenda 01:20 do dia 10"       igual x "jq -r .spec.schedule <<<'$cj'" "20 1 10 * *"
    confere "histórico: 4 sucessos, 1 falha" igual x "jq -r '\"\(.spec.successfulJobsHistoryLimit)-\(.spec.failedJobsHistoryLimit)\"' <<<'$cj'" "4-1"
    confere "SA operador-rotina"           igual x "jq -r .spec.jobTemplate.spec.template.spec.serviceAccountName <<<'$cj'" operador-rotina
    confere "imagem ubi-minimal"           bash -c "jq -r '.spec.jobTemplate.spec.template.spec.containers[0].image' <<<'$cj' | grep -q ubi9/ubi-minimal"
    confere "suspenso (regra da Academia)" igual x "jq -r .spec.suspend <<<'$cj'" true
  else
    ac_fail "CronJob fechamento-mensal em ac-sim-rotina"
  fi
fi

if quero 17; then
  ac_title "Tarefa 17 — ResourceQuota"
  q="$(oc get quota sim-cota -n ac-sim-centro -o json 2>/dev/null || true)"
  if [[ -n "$q" ]]; then
    for par in requests.cpu=500m requests.memory=512Mi pods=5 services=4 replicationcontrollers=2 secrets=12; do
      k="${par%%=*}"; v="${par#*=}"
      alt="${k#requests.}"   # "cpu" e "memory" na quota equivalem a requests.cpu e requests.memory
      confere "$k = $v" igual x "jq -r '.spec.hard[\"$k\"] // .spec.hard[\"$alt\"]' <<<'$q'" "$v"
    done
  else
    ac_fail "ResourceQuota sim-cota em ac-sim-centro"
  fi
fi

ac_title "Resumo"
printf 'OK=%d FALHA=%d AVISO=%d PULADO=%d — autoavaliação, sem nota.\n' "$ACADEMY_N_OK" "$ACADEMY_N_FAIL" "$ACADEMY_N_WARN" "$ACADEMY_N_SKIP"
