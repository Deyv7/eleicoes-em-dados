-- T08 — Totais do mart por ano e turno iguais aos totais independentes de referência,
-- calculados a partir da fonte antes da criação do mart (docs/validacao-fonte.md).
-- Não lê a fonte. Retorna as combinações com qualquer divergência.
with referencia as (
    select * from unnest([
        struct(2018 as ano, 1 as turno, 19 as linhas, 2085825 as eleitorado_apto, 1695724 as comparecimento, 390101 as abstencoes),
        struct(2018, 2, 19, 2086086, 1691396, 394690),
        struct(2022, 1, 19, 2206996, 1819900, 387096),
        struct(2022, 2, 19, 2207628, 1838492, 369136)
    ])
),

mart as (
    select
        ano,
        turno,
        count(*) as linhas,
        sum(eleitorado_apto) as eleitorado_apto,
        sum(comparecimento) as comparecimento,
        sum(abstencoes) as abstencoes
    from {{ ref('mart_participacao_zona') }}
    group by ano, turno
)

select
    coalesce(r.ano, m.ano) as ano,
    coalesce(r.turno, m.turno) as turno,
    r.linhas as linhas_ref,
    m.linhas as linhas_mart,
    r.eleitorado_apto as eleitorado_apto_ref,
    m.eleitorado_apto as eleitorado_apto_mart,
    r.comparecimento as comparecimento_ref,
    m.comparecimento as comparecimento_mart,
    r.abstencoes as abstencoes_ref,
    m.abstencoes as abstencoes_mart
from referencia as r
full outer join mart as m
    on r.ano = m.ano
    and r.turno = m.turno
where r.ano is null
   or m.ano is null
   or r.linhas <> m.linhas
   or r.eleitorado_apto <> m.eleitorado_apto
   or r.comparecimento <> m.comparecimento
   or r.abstencoes <> m.abstencoes
