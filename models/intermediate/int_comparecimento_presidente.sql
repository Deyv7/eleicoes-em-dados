select *
from {{ ref('stg_tse__detalhes_votacao') }}
where cargo = 'presidente'
  and tipo_eleicao = 'eleicao ordinaria'
  and turno in (1, 2)
