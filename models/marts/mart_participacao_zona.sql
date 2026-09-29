select
    ano,
    turno,
    zona,
    sigla_uf,
    cargo,
    tipo_eleicao,
    id_eleicao,
    id_municipio_tse,
    eleitorado_apto,
    comparecimento,
    abstencoes,
    safe_divide(comparecimento, eleitorado_apto) as taxa_comparecimento,
    safe_divide(abstencoes, eleitorado_apto) as taxa_abstencao,
    concat(cast(ano as string), '-', cast(turno as string), '-', zona)
        as chave_zona_eleicao_turno
from {{ ref('int_comparecimento_presidente') }}
