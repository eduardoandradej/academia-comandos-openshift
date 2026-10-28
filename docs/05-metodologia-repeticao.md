# Metodologia de repetição

> Menos leitura passiva, mais terminal. A repetição deliberada é uma metodologia de estudo, não uma promessa de
> habilidade automática.

## As 6 camadas de cada assunto

| Camada | Pergunta | Onde aparece no exercício |
|---|---|---|
| 1. Entender | o que é, para que serve, quais flags? | Conceito, fichas |
| 2. Observar | o que o cluster mostra agora? | Comandos guiados (leitura) |
| 3. Executar | consigo criar/alterar no meu projeto? | Comandos guiados (AMARELO) |
| 4. Repetir | consigo variar sem olhar? | Repetições |
| 5. Diagnosticar | consigo achar a causa de uma falha provocada? | Diagnóstico controlado, cenários |
| 6. Consolidar | lembro amanhã, em 7 e em 30 dias? | Desafio sem pista, Validação, Ficha de revisão |

## Séries

- **5×** — o mesmo comando com argumentos diferentes.
- **10×** — construir, consultar, corrigir o mesmo recurso, sem multiplicar workloads (apague antes de repetir).
- **20×** — circuito integrado de comandos curtos, removendo pistas (CLI-015, CON-015).

## Modos

| Modo | Como | Exemplo |
|---|---|---|
| Flash | dado o cenário, qual comando? | ORI-010 |
| Reverso | dada a saída, qual comando a produziu? | CON-015 (circuito) |
| Comparação | executar alternativas e justificar diferenças | CLI-013, CON-013 |
| Incidente | só o sintoma; investigar por hipótese | `cenarios/troubleshooting/` |
| Operador | ler saúde de componentes reais, só leitura | ORI-006 a ORI-008 |
| Revisão | revisitar em D+1, D+3, D+7, D+14, D+30 | ficha de cada exercício |

## Revisão espaçada

Use `scripts/academy review <ID>` para ver a ficha e registre **fora do repositório** (por exemplo,
`~/academia-progresso/`), copiando [`progresso/modelo-revisoes.md`](../progresso/modelo-revisoes.md). Nenhum script
grava seu progresso automaticamente.

## Regras de ouro

1. Digite; não cole.
2. Antes de executar, diga em voz alta o que espera ver.
3. Toda mutação termina com verificação explícita e limpeza.
4. Errou? Ótimo: leia a mensagem inteira antes de tentar de novo.
