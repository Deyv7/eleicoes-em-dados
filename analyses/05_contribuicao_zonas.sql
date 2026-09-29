select ano, turno, zona, abstencoes,
    safe_divide(abstencoes, sum(abstencoes) over (
        partition by ano, turno
    )) as participacao_abstencoes_df
from {{ ref('mart_participacao_zona') }}
order by ano, turno, participacao_abstencoes_df desc, zona
