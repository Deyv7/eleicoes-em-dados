-- T03 — Domínios do recorte: DF, 2018/2022, turnos 1 e 2, presidente, eleição ordinária,
-- zona como texto não vazio e sem espaços nas bordas.
select *
from {{ ref('mart_participacao_zona') }}
where ano not in (2018, 2022)
   or turno not in (1, 2)
   or sigla_uf <> 'DF'
   or cargo <> 'presidente'
   or tipo_eleicao <> 'eleicao ordinaria'
   or trim(zona) = ''
   or zona <> trim(zona)
