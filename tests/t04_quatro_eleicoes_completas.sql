-- T04 — As quatro combinações ano × turno existem e cada uma tem 19 zonas
-- (referência: docs/validacao-fonte.md). Retorna combinações ausentes ou incompletas.
with esperadas as (
    select ano, turno
    from unnest([2018, 2022]) as ano
    cross join unnest([1, 2]) as turno
),

observadas as (
    select
        ano,
        turno,
        count(*) as linhas,
        count(distinct zona) as zonas
    from {{ ref('mart_participacao_zona') }}
    group by ano, turno
)

select
    coalesce(e.ano, o.ano) as ano,
    coalesce(e.turno, o.turno) as turno,
    o.linhas,
    o.zonas
from esperadas as e
full outer join observadas as o
    on e.ano = o.ano
    and e.turno = o.turno
where e.ano is null
   or o.ano is null
   or o.linhas <> 19
   or o.zonas <> 19
