-- Comparação agregada do DF, mesmo turno, em pontos percentuais.
with taxas as (
    select ano, turno,
        safe_divide(sum(abstencoes), sum(eleitorado_apto)) as taxa_abstencao
    from {{ ref('mart_participacao_zona') }}
    group by ano, turno
)
select ano, turno, taxa_abstencao,
    100 * (taxa_abstencao - lag(taxa_abstencao) over (
        partition by turno order by ano
    )) as variacao_pp
from taxas
order by turno, ano
