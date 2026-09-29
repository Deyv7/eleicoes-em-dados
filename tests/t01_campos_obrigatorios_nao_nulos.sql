-- T01 — Campos de identificação e contagens obrigatórios (contrato: sem NULL, sem zero no lugar de ausente).
-- Retorna as linhas com algum campo obrigatório nulo.
select *
from {{ ref('mart_participacao_zona') }}
where ano is null
   or turno is null
   or zona is null
   or sigla_uf is null
   or cargo is null
   or tipo_eleicao is null
   or id_eleicao is null
   or id_municipio_tse is null
   or eleitorado_apto is null
   or comparecimento is null
   or abstencoes is null
   or chave_zona_eleicao_turno is null
