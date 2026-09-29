"""Executa as cinco análises compiladas, com dry runs e evidências de jobs."""
import json
from pathlib import Path
from google.cloud import bigquery

root = Path(__file__).resolve().parents[1]
client = bigquery.Client(project='eleitorado', location='US')
manifest = json.loads((root / 'target/manifest.json').read_text(encoding='utf-8'))
results = {}
for node in manifest['nodes'].values():
    if node['resource_type'] != 'analysis' or not node['name'][:2].isdigit():
        continue
    sql = node['compiled_code']
    dry = client.query(sql, job_config=bigquery.QueryJobConfig(dry_run=True, use_query_cache=False))
    if dry.total_bytes_processed > 100_000_000:
        raise RuntimeError('Consulta excede 100 MB')
    job = client.query(sql, job_config=bigquery.QueryJobConfig(use_query_cache=False, maximum_bytes_billed=100_000_000))
    rows = [dict(row) for row in job.result()]
    results[node['name']] = {'sql': sql, 'estimated_bytes': dry.total_bytes_processed,
        'processed_bytes': job.total_bytes_processed, 'billed_bytes': job.total_bytes_billed,
        'job_id': job.job_id, 'cache_hit': job.cache_hit, 'rows': rows}
    print(node['name'], len(rows), 'linhas;', job.total_bytes_processed, 'bytes')
(root / 'analyses/evidencias/analises.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
