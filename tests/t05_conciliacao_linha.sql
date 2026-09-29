-- T05 — Conciliação por linha: eleitorado_apto = comparecimento + abstencoes.
select
    ano,
    turno,
    zona,
    eleitorado_apto,
    comparecimento,
    abstencoes,
    eleitorado_apto - (comparecimento + abstencoes) as diferenca
from {{ ref('mart_participacao_zona') }}
where eleitorado_apto <> comparecimento + abstencoes
