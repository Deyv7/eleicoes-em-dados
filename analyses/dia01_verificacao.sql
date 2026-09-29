-- Dia 1 — verificações da fonte antes de modelar.
-- Tabela: basedosdados.br_tse_eleicoes.detalhes_votacao_municipio_zona
-- Fonte particionada por faixa de ano e clusterizada por sigla_uf.
-- Antes de rodar, conferir no canto superior direito do editor quantos bytes ela vai processar.


-- 1. A conciliação fecha? aptos deveria ser comparecimento + abstencoes.
--    Resultado esperado: nenhuma linha com diferenca <> 0.
SELECT
  ano,
  turno,
  cargo,
  zona,
  aptos,
  comparecimento,
  abstencoes,
  aptos - (comparecimento + abstencoes) AS diferenca
FROM `basedosdados.br_tse_eleicoes.detalhes_votacao_municipio_zona`
WHERE ano IN (2018, 2022)
  AND sigla_uf = 'DF'
  AND (aptos IS NULL OR comparecimento IS NULL OR abstencoes IS NULL
       OR aptos - (comparecimento + abstencoes) <> 0)
ORDER BY ano, turno, cargo, zona;


-- 2. O comparecimento muda entre cargos na mesma zona e turno?
--    Se valores_distintos > 1 em alguma linha, é obrigatório fixar um cargo no mart.
SELECT
  ano,
  turno,
  zona,
  COUNT(DISTINCT cargo) AS cargos,
  COUNT(DISTINCT comparecimento) AS valores_distintos,
  MIN(comparecimento) AS menor,
  MAX(comparecimento) AS maior
FROM `basedosdados.br_tse_eleicoes.detalhes_votacao_municipio_zona`
WHERE ano IN (2018, 2022)
  AND sigla_uf = 'DF'
GROUP BY ano, turno, zona
ORDER BY valores_distintos DESC, ano, turno, zona;


-- 3. Uma olhada no recorte final (cargo presidente): quantas zonas por ano e turno?
SELECT
  ano,
  turno,
  COUNT(*) AS linhas,
  COUNT(DISTINCT zona) AS zonas,
  SUM(aptos) AS aptos,
  SUM(comparecimento) AS comparecimento,
  SUM(abstencoes) AS abstencoes
FROM `basedosdados.br_tse_eleicoes.detalhes_votacao_municipio_zona`
WHERE ano IN (2018, 2022)
  AND sigla_uf = 'DF'
  AND LOWER(cargo) = 'presidente'
GROUP BY ano, turno
ORDER BY ano, turno;
