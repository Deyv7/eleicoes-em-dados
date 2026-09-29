# Contrato dos dados — v1

Responsável: Codex. Validado contra a fonte em 29/09/2026. Contrato liberado para Claude implementar testes e BI. Mart construído e disponível; execução e reprodução registradas em `docs/reproducao.md`.

## Fonte e filtros

- Source dbt: `source('tse', 'detalhes_votacao_municipio_zona')`.
- Origem: `basedosdados.br_tse_eleicoes.detalhes_votacao_municipio_zona`.
- Região: `US`; partição por faixa inteira de `ano`; clustering por `sigla_uf`.
- `ano IN (2018, 2022)`, `sigla_uf = 'DF'`, `turno IN (1, 2)`.
- Após TRIM/LOWER: `cargo = 'presidente'` e `tipo_eleicao = 'eleicao ordinaria'`.
- Eleições presidenciais observadas: 295 (2018/1), 296 (2018/2), 544 (2022/1), 545 (2022/2). IDs documentados, sem filtro adicional por ID.
- Apenas um município TSE em cada grupo. A chave final foi verificada, sem deduplicação artificial.

## Modelos e interface

`stg_tse__detalhes_votacao` (view) → `int_comparecimento_presidente` (view) → `mart_participacao_zona` (table).

Tabela para o Power BI: `eleitorado.eleicoes_em_dados.mart_participacao_zona`.

Uma linha representa uma zona do DF em um ano e turno para presidente em eleição ordinária. Chave natural: `ano, turno, zona`. Não há agregação nem DISTINCT na construção do mart.

| Coluna | Tipo BigQuery | Regra |
|---|---|---|
| ano | INT64 | 2018 ou 2022 |
| turno | INT64 | 1 ou 2 |
| zona | STRING | Texto não vazio; preservar identificador da fonte |
| sigla_uf | STRING | DF |
| cargo | STRING | presidente |
| tipo_eleicao | STRING | eleicao ordinaria |
| id_eleicao | STRING | Identificador da fonte |
| id_municipio_tse | STRING | Identificador da fonte |
| eleitorado_apto | INT64 | Coluna `aptos` renomeada; >= 0 |
| comparecimento | INT64 | >= 0 |
| abstencoes | INT64 | >= 0 |
| taxa_comparecimento | FLOAT64 | SAFE_DIVIDE(comparecimento, eleitorado_apto) |
| taxa_abstencao | FLOAT64 | SAFE_DIVIDE(abstencoes, eleitorado_apto) |
| chave_zona_eleicao_turno | STRING | CONCAT(ano, '-', turno, '-', zona), por exemplo 2018-1-1 |

## Qualidade e regras de BI

- Campos de identificação e contagens obrigatórios, sem NULL. Não substituir dados ausentes por zero.
- `eleitorado_apto = comparecimento + abstencoes` em cada linha.
- Taxas entre 0 e 1 para denominador positivo; ambas NULL se eleitorado_apto = 0.
- Os quatro grupos de ano/turno têm 19 linhas cada; total 76. Valores de referência em `docs/validacao-fonte.md`.
- Taxa agregada: dividir soma de abstenções pela soma de eleitorado_apto; nunca média simples das taxas.
- Para exibir diferença em pontos percentuais como número decimal: `(taxa_2022 - taxa_2018) * 100`.
- Cartões exigem um único ano e turno. Não apresentar soma entre eleições como pessoas únicas.
- Rankings por zona são válidos dentro da eleição. Comparações entre anos serão do DF como um todo: continuidade territorial das zonas não foi comprovada.
- Não interpretar a pequena diferença de aptos entre turnos como erro nem forçar igualdade; os valores são os informados pela fonte.

## Passagem para Claude

Atualizar rascunhos que usam `aptos`: o nome final é **eleitorado_apto**. Colunas de cargo e tipo_eleicao permanecem no mart. Atualizar o layout para remover a comparação territorial por zona entre 2018 e 2022 enquanto não houver comprovação dos limites. Substituir por tabela de detalhe ou contribuição das zonas para as abstenções no ano/turno escolhido.

Escrever testes singulares em `tests/`. Os testes genéricos de chave/domínios serão mantidos por Codex em `models/`. A demonstração inválida deve ficar desativada por padrão com `var('demo_falha', false)`.
