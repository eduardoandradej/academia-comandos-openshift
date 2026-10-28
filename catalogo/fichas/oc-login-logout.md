# Ficha: `oc login` e `oc logout`

> **Impacto:** MUTAÇÃO LOCAL REVERSÍVEL (kubeconfig e token de sessão) · **Perfil mínimo:** usuário com credenciais · **Status:** proposto (sintaxe conferida na ajuda do cliente 4.x; validar no seu `--help`) · **Usado em:** [ORI-004](../../trilhas/00-orientacao/exercicios/ORI-004.md), [CLI-004](../../trilhas/01-cli/exercicios/CLI-004.md)

## Quando usar

Para obter um token OAuth e gravá-lo no kubeconfig **em uso**; `oc logout` revoga o token. Sempre defina `KUBECONFIG` para o arquivo do perfil antes.

## Forma canônica

```bash
export KUBECONFIG="$HOME/.kube/ac-developer.kubeconfig"
oc login https://api.ocp.example.lab:6443 -u developer
```

## Sintaxe

```text
oc login [URL] [-u USUÁRIO] [--certificate-authority=ARQ] [--insecure-skip-tls-verify]
oc logout
```

## Exemplos no HomeLab

```bash
export KUBECONFIG="$HOME/.kube/ac-developer.kubeconfig"
oc login https://api.ocp.example.lab:6443 -u developer --certificate-authority="$HOME/.kube/ocp-sno-ca.crt"
oc login -u developer                      # reautentica no servidor do contexto atual
oc logout
```

## Flags principais

| Flag | Efeito |
|---|---|
| `-u`, `--username` | usuário; a senha é pedida no prompt |
| `--server` | URL da API (ou posicional) |
| `--certificate-authority` | CA para validar a API |
| `--insecure-skip-tls-verify` | não valida TLS — **só** no HomeLab |
| `--token` | usa token existente (evite: fica no histórico) |

## Comparação com comandos próximos

| Comando | Diferença |
|---|---|
| `oc config use-context` | troca de contexto sem autenticar |
| `oc logout` | revoga o token no servidor e remove do arquivo |
| apagar o kubeconfig | remove localmente, mas o token continua válido até expirar |

## Antes e depois

Antes: `printenv KUBECONFIG` (nunca o do instalador). Depois: `oc whoami`, `chmod 600 "$KUBECONFIG"`.

## Saída típica (ilustrativa)

Formato aproximado; nomes, números e versões do seu cluster vão diferir.

```text
Login successful.

You have access to N projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "ac01-cli".
```

## Erros comuns

- `Login failed (401 Unauthorized)`: usuário/senha ou provedor.
- `x509: certificate signed by unknown authority`: CA não informada ou errada.
- Token gravado no arquivo errado: `KUBECONFIG` não foi definido antes.

## Ajuda e documentação

```bash
oc login --help
oc logout --help
```

Documentação oficial 4.22: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.22](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22) — seção *CLI tools → OpenShift CLI (oc)*. Os links profundos mudam entre versões; navegue a partir da página da versão.

## Como desfazer

`oc logout` na sessão; para remover o perfil: `rm ~/.kube/ac-<perfil>.kubeconfig` (depois do logout).
