"""Dry run dos modelos/testes compilados, inclusive antes de criar as views.

Execute dbt compile antes. Não executa o SQL nem altera o warehouse.
"""
import json
from pathlib import Path
from google.cloud import bigquery

ROOT = Path(__file__).resolve().parents[1]
manifest = json.loads((ROOT / 'target/manifest.json').read_text(encoding='utf-8'))
models = {k: v for k, v in manifest['nodes'].items() if v['resource_type'] == 'model'}
client = bigquery.Client(project='eleitorado', location='US')

def expand(node, seen=frozenset()):
    sql = node['compiled_code']
    for dep in node['depends_on']['nodes']:
        if dep in models:
            if dep in seen:
                raise RuntimeError('Dependência circular')
            sql = sql.replace(models[dep]['relation_name'], '(' + expand(models[dep], seen | {dep}) + ')')
    return sql

results = []
for node in manifest['nodes'].values():
    if node['resource_type'] not in ('model', 'test') or not node.get('compiled_code'):
        continue
    sql = expand(node)
    job = client.query(sql, job_config=bigquery.QueryJobConfig(dry_run=True, use_query_cache=False))
    size = job.total_bytes_processed
    if size is None or size > 100_000_000:
        raise RuntimeError(f"Estimativa excede limite ou indisponível: {node['name']}: {size}")
    results.append({'node': node['unique_id'], 'estimated_bytes': size})
    print(node['name'], size)
out = ROOT / 'analyses/evidencias'
out.mkdir(exist_ok=True)
(out / 'preflight.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
