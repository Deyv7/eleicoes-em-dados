# Dashboard — layout e montagem

Responsável: Deyvid Prado. Relatório de uma página no Power BI Desktop (`dashboard/eleicoes-em-dados.pbip`), alimentado apenas pelo mart `eleitorado.eleicoes_em_dados.mart_participacao_zona`.

> Status: **modelo pronto e conferido** (tabela importada, 9 medidas criadas e validadas contra as evidências SQL em 29/09/2026). **Visuais montados** no projeto `dashboard/eleicoes-em-dados.pbip` (PBIR) e conferidos em 2022/2º e 2018/2º turno. Prints: `docs/apresentacao/`.

## Perguntas que a página responde

1. Quanto do eleitorado do DF compareceu e se absteve em cada eleição presidencial de 2018 e 2022?
2. A abstenção do DF como um todo subiu ou caiu entre 2018 e 2022, em cada turno?
3. Dentro de uma eleição, quais zonas têm maior taxa de abstenção e quanto cada uma pesa no total de abstenções?

**Fora do escopo:** comparar uma mesma zona entre 2018 e 2022. A continuidade territorial das zonas não foi comprovada (`docs/contrato-dados.md`); comparações entre anos são só do DF agregado.

## Layout (página única, 16:9)

```
┌──────────────────────────────────────────────────────────────────────┐
│ Participação eleitoral no DF — Presidente 2018 e 2022                │
│ Filtros (seleção única): [Ano ▾] [Turno ▾]                           │
├──────────────┬──────────────┬──────────────┬─────────────────────────┤
│ Eleitorado   │ Comparecim.  │ Abstenções   │ Taxa de abstenção       │
│ apto         │              │              │                         │
├──────────────┴──────────────┴──┬───────────┴─────────────────────────┤
│ A. Taxa de abstenção do DF     │ B. Variação 2018 → 2022 do DF       │
│    por turno, 2018 × 2022      │    (cartão, p.p., turno do filtro)  │
│    (colunas agrupadas)         │                                     │
├────────────────────────────────┴─────────────────────────────────────┤
│ C. Taxa de abstenção por zona       │ D. Detalhe por zona            │
│    na eleição selecionada           │    (tabela: apto, abstenções,  │
│    (barras horizontais, ordenadas)  │    taxa, participação no DF)   │
├──────────────────────────────────────────────────────────────────────┤
│ Rodapé: fonte TSE/Base dos Dados · recorte DF, presidente, eleição   │
│ ordinária · zonas não comparáveis entre anos · link do repositório   │
└──────────────────────────────────────────────────────────────────────┘
```

## Design no Figma

Arquivo: [Eleições em Dados — Dashboard](https://www.figma.com/design/FgzlwmuTJ3orRSsiQ8BRHG/Elei%C3%A7%C3%B5es-em-Dados-%E2%80%94-Dashboard). Os dois frames têm 1280 × 720 px e foram criados via Figma MCP em 29/09/2026:

- **Fundo (Power BI)** (`2004:2`) — só cartões, títulos, subtítulos, rótulos dos KPIs e rodapé. Exportar como PNG 2x para `dashboard/fundo.png` e usar como plano de fundo da página.
- **Mockup (2022 · 2º turno)** (`2004:28`) — o mesmo fundo com os valores reais de 2022/2º turno e gráficos simplificados. Serve como referência de montagem, não como imagem final do portfólio: a imagem final deve ser um print do Power BI.

**Versão v2 (atual)**, com a paleta tirada da logo do TSE: **Fundo v2 (Power BI)** (`2005:2`) e **Mockup v2 (2022 · 2º turno)** (`2005:45`). Os frames v1 continuam no arquivo só para comparação.

- Paleta: azul `#5C719C` (2022, destaques), azul claro `#B7C1D6` (2018), amarelo `#FCC200` (marcadores e zona de maior taxa), verde `#577372` (variação e participação), texto `#1D1D1B`, secundário `#5F6B7A`, página `#EEF1F6`, cartões `#FFFFFF` com borda `#DDE2EB`.
- A logo do TSE aparece como **crédito da fonte dos dados**, e o rodapé traz "Projeto independente de portfólio, sem vínculo com o TSE". Não usar a logo de forma que sugira painel oficial.
- No Power BI, o cartão **Taxa de abstenção** fica sobre fundo azul: use valor em **branco**. Nos outros cartões, `#1D1D1B`. Barras do visual C em `#5C719C`; nas colunas do visual A, 2018 `#B7C1D6` e 2022 `#5C719C`.

Tipografia do Figma: Inter; no Power BI, Segoe UI.

### Posição dos visuais no Power BI (x, y, largura × altura)

Os títulos e rótulos já estão no fundo, então desligue título e rótulo de categoria nos visuais.

| Visual | x | y | L × A |
|---|---|---|---|
| Segmentador Ano (lista suspensa) | 872 | 24 | 180 × 40 |
| Segmentador Turno (lista suspensa) | 1076 | 24 | 180 × 40 |
| Cartão Eleitorado apto | 32 | 116 | 280 × 60 |
| Cartão Comparecimento | 344 | 116 | 280 × 60 |
| Cartão Abstenções | 656 | 116 | 280 × 60 |
| Cartão Taxa de abstenção | 968 | 116 | 280 × 60 |
| A. Colunas agrupadas | 36 | 248 | 576 × 164 |
| B. Cartão variação (p.p.) | 652 | 248 | 592 × 164 |
| C. Barras por zona | 36 | 484 | 576 × 180 |
| D. Tabela | 652 | 484 | 592 × 180 |

## Medidas no modelo (criadas via MCP)

Tabela `mart_participacao_zona`. Colunas de taxa por linha e a chave ficam ocultas; use sempre as medidas.

| Pasta | Medida | Definição |
|---|---|---|
| Contagens | Eleitorado apto (total) | `SUM(eleitorado_apto)` só com um ano e um turno no contexto; senão em branco |
| Contagens | Comparecimento (total) | idem, `comparecimento` |
| Contagens | Abstencoes (total) | idem, `abstencoes` |
| Taxas | Taxa de abstencao | `DIVIDE([Abstencoes (total)], [Eleitorado apto (total)])` — ponderada |
| Taxas | Taxa de comparecimento | `DIVIDE([Comparecimento (total)], [Eleitorado apto (total)])` |
| Comparacao DF | Taxa de abstencao DF 2018 | taxa com `ano = 2018`, ignorando filtro de zona |
| Comparacao DF | Taxa de abstencao DF 2022 | taxa com `ano = 2022`, ignorando filtro de zona |
| Comparacao DF | Variacao abstencao DF (p.p.) | `(DF 2022 − DF 2018) * 100` |
| Zonas | Participacao nas abstencoes do DF | abstenções da zona / abstenções do DF na mesma eleição |

As contagens ficam em branco quando mais de uma eleição está no contexto: o contrato proíbe somar eleições como pessoas únicas.

## Conferência das medidas (29/09/2026)

Consultas DAX no modelo carregado, comparadas a `docs/validacao-fonte.md` e `analyses/evidencias/analises.json`:

| Ano | Turno | Eleitorado apto | Comparecimento | Abstenções | Taxa de abstenção | Confere |
|---|---|---|---|---|---|---|
| 2018 | 1 | 2.085.825 | 1.695.724 | 390.101 | 18,70% | sim |
| 2018 | 2 | 2.086.086 | 1.691.396 | 394.690 | 18,92% | sim |
| 2022 | 1 | 2.206.996 | 1.819.900 | 387.096 | 17,54% | sim |
| 2022 | 2 | 2.207.628 | 1.838.492 | 369.136 | 16,72% | sim |

- Variação do DF: −1,16 p.p. (1º turno) e −2,20 p.p. (2º turno) — igual à análise `03_variacao_anos`.
- Participação da zona 16 nas abstenções de 2018/1: 7,42% — igual à análise `05_contribuicao_zonas`.
- Com filtro de zona aplicado, a variação continua sendo a do DF (proteção contra comparação territorial).

## Montagem dos visuais

O projeto final está salvo em `.pbip`, acompanhado das pastas `.Report` e `.SemanticModel`. O roteiro abaixo descreve a montagem já realizada; o PBIX inicial não contém os visuais finais.

1. **Filtros** — dois segmentadores (slicers) com `ano` e `turno`; em *Formatar → Configurações do segmentador*, ative **Seleção única**. Deixe 2022 / 2 selecionados por padrão.
2. **Cartões** — quatro cartões com `Eleitorado apto (total)`, `Comparecimento (total)`, `Abstencoes (total)`, `Taxa de abstencao`.
3. **A. Colunas agrupadas** — Eixo X: `turno`; Legenda: `ano`; Eixo Y: `Taxa de abstencao`. Em *Formatar → Editar interações*, desligue o efeito do segmentador **Ano** sobre este visual (ele compara os dois anos).
4. **B. Cartão** — `Variacao abstencao DF (p.p.)`, título "Variação da abstenção do DF, 2022 vs 2018 (p.p.)". Desligue também a interação do segmentador **Ano** sobre ele.
5. **C. Barras horizontais** — Eixo Y: `zona`; Eixo X: `Taxa de abstencao`; ordenar por `Taxa de abstencao` decrescente. Rótulos de dados ligados.
6. **D. Tabela** — `zona`, `Eleitorado apto (total)`, `Abstencoes (total)`, `Taxa de abstencao`, `Participacao nas abstencoes do DF`; ordenar por participação decrescente.
7. **Rodapé** — caixa de texto com fonte, recorte e o aviso "zonas não comparáveis entre 2018 e 2022".

Regras de apresentação: taxas em % com 1 casa; variação em p.p. com 2 casas, nunca em %; uma cor para as barras, com destaque apenas para a zona selecionada.

## Conexão e custo

- Conector Google BigQuery, modo Import, `BillingProject = "eleitorado"`, `UseStorageApi = false`.
- A consulta Power Query lê só o mart e seleciona 9 colunas (sem `sigla_uf`, `cargo`, `tipo_eleicao`, `id_*`, que são constantes no recorte).
- Autenticação Google feita pelo usuário no Power BI Desktop; nenhuma credencial fica no repositório.
- Atualizar só quando o mart mudar.

## Pendências

- Montagem e conferência visual concluídas em 2022/2º e 2018/2º turno; imagens em `docs/apresentacao/`.
- Para abrir a entrega, usar o PBIP com as pastas de relatório e modelo. Caches `.pbi/` e o PBIX inicial não são versionados.
