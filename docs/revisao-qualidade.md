# Revisão de qualidade

Responsável: Deyvid Prado. Registra os testes independentes do mart, a revisão do contrato de dados e as correções identificadas.

> Status: **testes integrados e aprovados.** Os 9 testes singulares passaram no `dbt build` executado em 29/09/2026 (3 modelos + 27 testes, `PASS=30 WARN=0 ERROR=0`), e a demonstração falhou com exatamente 3 violações, como esperado. Dashboard validado visualmente em 29/09/2026: 2022/2º e 2018/2º turno conferidos (cartões, barras visíveis e linhas da tabela) contra `docs/validacao-fonte.md` e `analyses/evidencias/analises.json`.

## Resultado oficial (dbt)

| Execução | Resultado | Evidência |
|---|---|---|
| `dbt build` | 3 modelos + 27 testes (18 genéricos + T01–T09) aprovados; `PASS=30 WARN=0 ERROR=0` | `analyses/evidencias/build_integrado.json` |
| `dbt test --select demo_falha_qualidade --vars "{demo_falha: true}"` | `fail`, `failures: 3`, exit code 1 (esperado); 3920 bytes processados | `analyses/evidencias/demo_qualidade.json` |

A demonstração foi desativada de novo depois da execução, então o build normal continua só com os 27 testes.

## Testes singulares

Cada arquivo retorna as linhas que violam a regra; o teste passa quando o resultado é vazio. Todos leem `ref('mart_participacao_zona')`; T09 lê também a fonte. Os testes genéricos (not_null, accepted_values, unique da chave concatenada) estão em `models/schema.yml`; os singulares abaixo são verificações independentes que não reutilizam os modelos intermediários.

| Id | Arquivo | Regra |
|---|---|---|
| T01 | `tests/t01_campos_obrigatorios_nao_nulos.sql` | Identificação, contagens e chave sem NULL |
| T02 | `tests/t02_chave_natural.sql` | `ano + turno + zona` único; `chave_zona_eleicao_turno` igual ao recálculo |
| T03 | `tests/t03_dominios_recorte.sql` | DF, 2018/2022, turnos 1/2, presidente, eleição ordinária; `zona` não vazia e sem espaços nas bordas |
| T04 | `tests/t04_quatro_eleicoes_completas.sql` | As 4 combinações ano × turno existem, cada uma com 19 linhas e 19 zonas |
| T05 | `tests/t05_conciliacao_linha.sql` | `eleitorado_apto = comparecimento + abstencoes` |
| T06 | `tests/t06_limites_contagens.sql` | Contagens `>= 0`; comparecimento e abstenções `<= eleitorado_apto` |
| T07 | `tests/t07_taxas.sql` | Com apto > 0: taxas em [0, 1], complementares e iguais ao recálculo (tolerância 1e-9). Com apto = 0: ambas NULL |
| T08 | `tests/t08_totais_referencia.sql` | Linhas e totais por ano e turno iguais aos totais de referência de `docs/validacao-fonte.md` |
| T09 | `tests/t09_linhas_vs_fonte.sql` | Comparação linha a linha com a fonte, reaplicando o recorte do contrato sem usar staging/intermediate |

### Validação prévia (consulta direta)

Antes da entrega, cada teste foi renderizado (ref/source substituídos pelas tabelas reais), estimado por dry run e executado somente leitura no BigQuery. Nenhuma tabela foi criada. Bytes estimados e processados coincidiram (cache desativado).

| Teste | Linhas retornadas | Bytes estimados | Bytes processados | Job |
|---|---|---|---|---|
| T01 | 0 | 8904 | 8904 | 6fd22177-b2f3-4109-a87a-8627f7761257 |
| T02 | 0 | 2292 | 2292 | d6d199c4-3a42-4beb-b982-98a7c79c3f34 |
| T03 | 0 | 8904 | 8904 | e8223bea-2aa3-4109-8d8e-202cdbcb5240 |
| T04 | 0 | 1488 | 1488 | 28a3f115-d82c-45e5-b523-0b8a507d4273 |
| T05 | 0 | 3312 | 3312 | 1a499c5b-292a-4e70-b33f-d5c70626774b |
| T06 | 0 | 3312 | 3312 | 36ba1a90-4d91-4ef2-8573-c18fa83952a6 |
| T07 | 0 | 4528 | 4528 | 53e3bed6-f49e-4b0c-b6f4-d72fb9884eae |
| T08 | 0 | 3040 | 3040 | df88b927-8f40-4589-bc8e-38604ab08dba |
| T09 | 0 | 6503377 | 6503377 | 7f3fe407-4f0c-43c3-8441-213aa23e5f4a |

A validação prévia foi confirmada pela execução oficial via dbt (seção "Resultado oficial").

## Demonstração controlada

- Arquivo: `tests/demo/demo_falha_qualidade.sql`, desativado por padrão com `config(enabled=var('demo_falha', false))`.
- Junta às 76 linhas reais do mart quatro linhas geradas em CTE (três casos inválidos, um deles duplicado) e aplica as regras de T02, T05 e T07. Nenhuma tabela é criada ou alterada.
- Execução: `dbt test --select demo_falha_qualidade --vars "{demo_falha: true}"`.
- Resultado esperado: **falha com 3 violações**, todas nas zonas injetadas:

| Zona injetada | Regra violada |
|---|---|
| `demo-conciliacao` | conciliação (1000 ≠ 800 + 150) |
| `demo-taxa` | taxa fora de [0, 1] (1,2) |
| `demo-duplicada` | chave duplicada |

Na validação prévia (job `6b2b8b4f-60d7-487e-af77-ac748028b913`) a consulta retornou exatamente essas 3 linhas e nenhuma linha real do mart.

## Revisão do contrato (v1)

Contrato lido em 29/09/2026. Sem inconsistências bloqueantes. Conferências:

- Nomes e tipos das colunas coincidem entre `docs/contrato-dados.md`, `models/schema.yml` e o mart consultado (`zona` STRING, contagens INT64, taxas FLOAT64).
- Granularidade `ano + turno + zona` confirmada por T02 e T04 (76 linhas, 19 por eleição).
- Totais do mart iguais à referência independente (T08) e linhas iguais à fonte (T09).
- Regra de taxa com denominador zero coberta por T07. Hoje não há zona com `eleitorado_apto = 0`; o ramo NULL fica como proteção.

Observações (não bloqueiam):

1. O contrato cita `ano` como partição e `sigla_uf` como clustering da fonte; o README antigo dizia "partições `ano`, `sigla_uf`". Corrigido no README.
2. O mart usava `select *` a partir do intermediário, e uma coluna nova entraria sem passar pelo contrato. **Resolvido:** o mart agora lista explicitamente as 14 colunas do contrato (conferido em `models/marts/mart_participacao_zona.sql`).

## Regras de uso no dashboard (do contrato)

- Taxas agregadas = soma de abstenções / soma de `eleitorado_apto`; nunca média das taxas das zonas.
- Cartões exigem um único ano e turno; não somar eleições como pessoas únicas.
- Rankings e contribuição por zona só **dentro** de uma eleição. Comparação entre anos apenas do DF como um todo: a continuidade territorial das zonas entre 2018 e 2022 não foi comprovada.

## Problemas encontrados

_Nenhum bloqueante._ A única sugestão (colunas explícitas no mart) foi aplicada.
