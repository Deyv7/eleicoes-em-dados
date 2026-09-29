select
    ano,
    turno,
    trim(zona) as zona,
    sigla_uf,
    lower(trim(cargo)) as cargo,
    lower(trim(tipo_eleicao)) as tipo_eleicao,
    id_eleicao,
    id_municipio_tse,
    aptos as eleitorado_apto,
    comparecimento,
    abstencoes
from {{ source('tse', 'detalhes_votacao_municipio_zona') }}
where ano in (2018, 2022)
  and sigla_uf = 'DF'
