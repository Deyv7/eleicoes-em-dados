-- T06 — Contagens não negativas e comparecimento/abstenções limitados ao eleitorado apto.
select
    ano,
    turno,
    zona,
    eleitorado_apto,
    comparecimento,
    abstencoes
from {{ ref('mart_participacao_zona') }}
where eleitorado_apto < 0
   or comparecimento < 0
   or abstencoes < 0
   or comparecimento > eleitorado_apto
   or abstencoes > eleitorado_apto
