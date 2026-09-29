-- T02 — Chave natural ano + turno + zona única e coerente com chave_zona_eleicao_turno.
-- Complementa o teste genérico de unicidade da chave concatenada: aqui a unicidade é
-- verificada nas colunas de origem e a chave é recalculada.
with duplicadas as (
    select
        ano,
        turno,
        zona,
        'chave natural duplicada' as problema
    from {{ ref('mart_participacao_zona') }}
    group by ano, turno, zona
    having count(*) > 1
),

chave_divergente as (
    select
        ano,
        turno,
        zona,
        'chave concatenada divergente' as problema
    from {{ ref('mart_participacao_zona') }}
    where chave_zona_eleicao_turno
        <> concat(cast(ano as string), '-', cast(turno as string), '-', zona)
)

select * from duplicadas
union all
select * from chave_divergente
