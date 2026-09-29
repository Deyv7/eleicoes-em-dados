with taxas as (
    select ano, turno,
        safe_divide(sum(comparecimento), sum(eleitorado_apto)) as taxa_comparecimento
    from {{ ref('mart_participacao_zona') }}
    group by ano, turno
)
select ano, turno, taxa_comparecimento,
    100 * (taxa_comparecimento - lag(taxa_comparecimento) over (
        partition by ano order by turno
    )) as variacao_pp
from taxas
order by ano, turno
