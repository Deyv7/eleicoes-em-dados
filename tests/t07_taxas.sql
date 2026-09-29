-- T07 — Taxas conforme o contrato:
--   eleitorado_apto > 0 → taxas não nulas, entre 0 e 1, complementares e iguais ao recálculo;
--   eleitorado_apto = 0 → ambas as taxas NULL.
-- Tolerância de 1e-9 para arredondamento de ponto flutuante.
select
    ano,
    turno,
    zona,
    eleitorado_apto,
    taxa_comparecimento,
    taxa_abstencao
from {{ ref('mart_participacao_zona') }}
where (
        eleitorado_apto > 0
        and (
            taxa_comparecimento is null
            or taxa_abstencao is null
            or taxa_comparecimento not between 0 and 1
            or taxa_abstencao not between 0 and 1
            or abs(taxa_comparecimento + taxa_abstencao - 1) > 1e-9
            or abs(taxa_comparecimento - comparecimento / eleitorado_apto) > 1e-9
            or abs(taxa_abstencao - abstencoes / eleitorado_apto) > 1e-9
        )
    )
    or (
        eleitorado_apto = 0
        and (taxa_comparecimento is not null or taxa_abstencao is not null)
    )
