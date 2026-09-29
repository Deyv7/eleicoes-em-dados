-- Rankings determinísticos por eleição; taxas nulas ficam no final.
select ano, turno, zona, eleitorado_apto, abstencoes, taxa_abstencao,
    row_number() over (
        partition by ano, turno order by taxa_abstencao desc nulls last, zona
    ) as ranking_maior_abstencao,
    row_number() over (
        partition by ano, turno order by taxa_abstencao asc nulls last, zona
    ) as ranking_menor_abstencao
from {{ ref('mart_participacao_zona') }}
order by ano, turno, ranking_maior_abstencao
