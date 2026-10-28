# Preparação do Helm (Trilha 14)

> **REQUER PREPARAÇÃO** — o cliente `helm` não vem instalado na `ocp-admin`. Este roteiro instala o binário **só para
> o usuário `student`** (sem `sudo`, sem pacotes do sistema) e mostra como conferir que ele usa o perfil certo.
> Nada é instalado no cluster: o Helm 3 é só um cliente.

## 1. Baixar o cliente da Red Hat (na `ocp-admin`, como `student`)

```bash
mkdir -p ~/bin ~/tmp/helm && cd ~/tmp/helm
curl -sSLO https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/helm-linux-amd64
curl -sSLO https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/sha256sum.txt
grep ' helm-linux-amd64$' sha256sum.txt | sha256sum -c -       # deve dizer: OK
install -m 0755 helm-linux-amd64 ~/bin/helm
cd ~ && rm -rf ~/tmp/helm
command -v helm && helm version
```

Alternativa: na Console, menu **?** → **Command Line Tools** → Helm 3 (mesmo binário). Se `~/bin` não estiver no
`PATH`, acrescente `export PATH="$HOME/bin:$PATH"` ao `~/.bashrc`.

## 2. Conferir a identidade que o Helm vai usar

O Helm lê o mesmo `KUBECONFIG` do `oc`. **Atenção:** o `~/.bashrc` do HomeLab exporta o kubeconfig do instalador
(`system:admin`). Um terminal novo, sem `ac-dev`, faria o Helm instalar como administrador do cluster.

```bash
source scripts/perfis.sh && ac-dev
oc whoami                         # developer
helm env | grep -E 'HELM_KUBECONTEXT|HELM_NAMESPACE'
echo "$KUBECONFIG"                # ~/.kube/ac-developer.kubeconfig
```

Todos os exercícios da Trilha 14 começam com essa conferência.

## 3. Repositórios públicos (opcional)

Só o HLM-013 usa um repositório remoto, e apenas para **ler** charts:

```bash
helm repo add openshift-helm-charts https://charts.openshift.io/
helm repo update
```

Remover depois: `helm repo remove openshift-helm-charts`. Os dados ficam em `~/.config/helm` e `~/.cache/helm`.

## Desfazer

```bash
rm -f ~/bin/helm
rm -rf ~/.config/helm ~/.cache/helm ~/.local/share/helm
```
