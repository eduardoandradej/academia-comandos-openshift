# Como contribuir

## Princípios

1. **Original**: nada copiado de PDFs, roteiros, figuras ou scripts da Red Hat. Cite temas, não transcreva.
2. **Executável e seguro**: todo exercício roda na `ocp-admin`, em projeto `acNN-*`, com rótulo da Academia e limpeza.
3. **Honesto**: marque o status (`proposto`, `testado pelo autor`, `validado pelo usuário`) e as dependências
   (**REQUER PREPARAÇÃO**, **NÃO DISPONÍVEL NO HOME LAB ATUAL**). Não crie pastas vazias nem `TODO` que simulem conteúdo.
4. **Sem segredos**: nada de kubeconfig, token, pull secret, chaves ou senhas reais.

## Novo exercício

1. Copie [`templates/exercicio.md`](templates/exercicio.md) para `trilhas/NN-tema/exercicios/XXX-NNN.md`.
2. Mantenha **todas** as seções, na ordem do modelo.
3. Gabarito em `solucoes/NN-tema/XXX-NNN.md`, a partir de [`templates/solucao.md`](templates/solucao.md).
4. Atualize o README da trilha, a [matriz](catalogo/matriz-competencias.md) e, se houver comando novo, o [índice](catalogo/indice-comandos.md).

## Scripts

- `#!/usr/bin/env bash` e `set -euo pipefail`.
- Leitura por padrão; mutação só com flag explícita, confirmação e escopo `ac*-*` + rótulo.
- Nunca `-A`, `--all`, `openshift-*`, `kube-*` ou operações VERMELHAS.
- Adicione casos em `tests/run-tests.sh` (o `oc` simulado fica em `tests/mocks/oc`).

## Antes do commit

```bash
markdownlint-cli2                       # Markdown
yamllint -c .yamllint.yaml .            # YAML
shellcheck scripts/*.sh scripts/academy scripts/lib/*.sh scripts/dev/*.sh tests/run-tests.sh tests/mocks/oc
scripts/dev/check-repo.sh               # estrutura, links internos, gabaritos e padrões de segredo
tests/run-tests.sh                      # testes offline dos scripts
git status                              # confira o que vai entrar
```

## Commits

Pequenos e em português: `docs: ...`, `feat: ...`, `fix: ...`, `test: ...`. Nunca `git push --force` em `main`.
