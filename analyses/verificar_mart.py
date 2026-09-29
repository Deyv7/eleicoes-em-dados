"""Compara cada linha do mart à extração independente da fonte.

Complementa (não substitui) os testes singulares de revisão da Claude.
"""
import json
import math
import os
from collections import Counter
from pathlib import Path
from google.cloud import bigquery

root = Path(__file__).resolve().parents[1]
project = os.environ.get('BIGQUERY_PROJECT', 'eleitorado')
dataset = os.environ.get('DBT_DATASET', 'eleicoes_em_dados')
table_id = f'{project}.{dataset}.mart_participacao_zona'
client = bigquery.Client(project=project, location='US')
sql = f'SELECT * FROM `{table_id}` ORDER BY ano, turno, zona'
dry = client.query(sql, job_config=bigquery.QueryJobConfig(dry_run=True, use_query_cache=False))
assert dry.total_bytes_processed <= 100_000_000
job = client.query(sql, job_config=bigquery.QueryJobConfig(use_query_cache=False, maximum_bytes_billed=100_000_000))
rows = [dict(r) for r in job.result()]
source = json.loads((root / 'analyses/evidencias/fonte.json').read_text(encoding='utf-8'))['queries']['presidente']['rows']
source = [r for r in source if r['tipo_eleicao'].strip().lower() == 'eleicao ordinaria' and r['turno'] in (1,2)]
key = lambda r: (r['ano'],r['turno'],r['zona'].strip())
expected = {key(r): r for r in source}
assert len(expected) == len(source) == len(rows) == 76
assert Counter((r['ano'],r['turno']) for r in rows) == {(2018,1):19,(2018,2):19,(2022,1):19,(2022,2):19}
assert len({key(r) for r in rows}) == len(rows)
assert {key(r) for r in rows} == set(expected)
for row in rows:
    ref = expected[key(row)]
    assert row['sigla_uf'] == 'DF' and row['cargo'] == 'presidente'
    assert row['tipo_eleicao'] == 'eleicao ordinaria'
    assert isinstance(row['zona'], str) and row['zona'].strip()
    assert row['chave_zona_eleicao_turno'] == '-'.join(map(str,key(row)))
    for field, original in [('eleitorado_apto','aptos'),('comparecimento','comparecimento'),('abstencoes','abstencoes')]:
        assert row[field] is not None and row[field] >= 0
        assert row[field] == ref[original]
    assert row['eleitorado_apto'] == row['comparecimento'] + row['abstencoes']
    for rate, field in [('taxa_comparecimento','comparecimento'),('taxa_abstencao','abstencoes')]:
        if row['eleitorado_apto'] == 0:
            assert row[rate] is None
        else:
            assert 0 <= row[rate] <= 1
            assert math.isclose(row[rate], row[field]/row['eleitorado_apto'], abs_tol=1e-12)
meta = client.get_table(table_id)
out = {'table':table_id,'rows':len(rows),'status':'passed','checks':['coverage','unique_key','required_counts','nonnegative_counts','source_row_equality','reconciliation','rates','fixed_domains'],
    'schema':{field.name:field.field_type for field in meta.schema},
    'estimated_bytes':dry.total_bytes_processed,'processed_bytes':job.total_bytes_processed,
    'job_id':job.job_id,'expires':str(meta.expires)}
assert out['schema']['zona'] == 'STRING'
(root / f'analyses/evidencias/verificacao_{dataset}.json').write_text(json.dumps(out,indent=2),encoding='utf-8')
print(json.dumps(out))
