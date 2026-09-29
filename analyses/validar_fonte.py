"""Valida o recorte com dry run prévio; grava evidências sem credenciais."""
import json
from pathlib import Path
from datetime import datetime, timezone
from google.cloud import bigquery

ROOT = Path(__file__).resolve().parents[1]
SOURCE = 'basedosdados.br_tse_eleicoes.detalhes_votacao_municipio_zona'
client = bigquery.Client(project='eleitorado', location='US')
table = client.get_table(SOURCE)
queries = {
    'perfil': f"""SELECT ano, turno, cargo, tipo_eleicao, id_eleicao,
      COUNT(*) AS linhas, COUNT(DISTINCT zona) AS zonas,
      COUNT(DISTINCT id_municipio_tse) AS municipios,
      COUNTIF(aptos IS NULL OR comparecimento IS NULL OR abstencoes IS NULL) AS nulos,
      COUNTIF(aptos != comparecimento + abstencoes) AS divergencias
    FROM `{SOURCE}` WHERE ano IN (2018,2022) AND sigla_uf = 'DF'
    GROUP BY ALL ORDER BY ano,turno,cargo,tipo_eleicao,id_eleicao""",
    'presidente': f"""SELECT ano, turno, zona, sigla_uf, cargo, tipo_eleicao,
      id_eleicao, id_municipio_tse, aptos, comparecimento, abstencoes
    FROM `{SOURCE}` WHERE ano IN (2018,2022) AND sigla_uf = 'DF'
      AND LOWER(TRIM(cargo)) = 'presidente'
    ORDER BY ano,turno,zona""",
}
evidence = {'checked_at': datetime.now(timezone.utc).isoformat(),
    'source': SOURCE, 'location': table.location,
    'range_partitioning': table.to_api_repr().get('rangePartitioning'),
    'clustering': table.clustering_fields, 'queries': {}}
for name, sql in queries.items():
    dry = client.query(sql, job_config=bigquery.QueryJobConfig(dry_run=True, use_query_cache=False))
    estimate = dry.total_bytes_processed
    if estimate > 100_000_000:
        raise RuntimeError(f'{name}: estimativa excede 100 MB: {estimate}')
    job = client.query(sql, job_config=bigquery.QueryJobConfig(
        use_query_cache=False, maximum_bytes_billed=100_000_000))
    rows = [dict(row) for row in job.result()]
    evidence['queries'][name] = {'sql': sql, 'estimated_bytes': estimate,
        'processed_bytes': job.total_bytes_processed, 'billed_bytes': job.total_bytes_billed,
        'cache_hit': job.cache_hit, 'job_id': job.job_id, 'rows': rows}
    print(name, 'linhas:', len(rows), 'estimados:', estimate,
          'processados:', job.total_bytes_processed)
out = ROOT / 'analyses/evidencias'
out.mkdir(exist_ok=True)
(out / 'fonte.json').write_text(json.dumps(evidence, indent=2, ensure_ascii=False), encoding='utf-8')
