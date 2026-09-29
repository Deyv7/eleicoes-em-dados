-- Taxas ponderadas do DF por ano e turno.
select ano, turno,
    sum(eleitorado_apto) as eleitorado_apto,
    sum(comparecimento) as comparecimento,
    sum(abstencoes) as abstencoes,
    safe_divide(sum(abstencoes), sum(eleitorado_apto)) as taxa_abstencao
from {{ ref('mart_participacao_zona') }}
group by ano, turno
order by ano, turno
