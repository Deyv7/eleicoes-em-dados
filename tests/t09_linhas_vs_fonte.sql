-- T09 — Comparação linha a linha do mart com a fonte, reaplicando o recorte do contrato
-- de forma independente dos modelos (sem ref para staging/intermediate).
-- Lê a fonte filtrando as partições (ano) e o cluster (sigla_uf), só com as colunas necessárias.
-- Retorna linhas presentes em apenas um dos lados ou com contagens divergentes.
with fonte as (
    select
        ano,
        turno,
        trim(zona) as zona,
        aptos as eleitorado_apto,
        comparecimento,
        abstencoes
    from {{ source('tse', 'detalhes_votacao_municipio_zona') }}
    where ano in (2018, 2022)
      and sigla_uf = 'DF'
      and turno in (1, 2)
      and lower(trim(cargo)) = 'presidente'
      and lower(trim(tipo_eleicao)) = 'eleicao ordinaria'
),

mart as (
    select ano, turno, zona, eleitorado_apto, comparecimento, abstencoes
    from {{ ref('mart_participacao_zona') }}
)

select
    coalesce(f.ano, m.ano) as ano,
    coalesce(f.turno, m.turno) as turno,
    coalesce(f.zona, m.zona) as zona,
    case
        when m.zona is null then 'ausente no mart'
        when f.zona is null then 'ausente na fonte'
        else 'contagem divergente'
    end as problema
from fonte as f
full outer join mart as m
    on f.ano = m.ano
    and f.turno = m.turno
    and f.zona = m.zona
where f.zona is null
   or m.zona is null
   or f.eleitorado_apto <> m.eleitorado_apto
   or f.comparecimento <> m.comparecimento
   or f.abstencoes <> m.abstencoes
