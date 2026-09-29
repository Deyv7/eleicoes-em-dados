"""Experimento pequeno e reproduzível; não promete ganhos em tabelas minúsculas.

Cria apenas três cópias do mart (76 linhas cada), com expiração de 24 horas.
"""
import json
from pathlib import Path
from google.cloud import bigquery

root = Path(__file__).resolve().parents[1]
client = bigquery.Client(project='eleitorado', location='US')
evidence = {}

def run(name, sql, estimate_sql=None):
    dry = client.query(estimate_sql or sql, job_config=bigquery.QueryJobConfig(dry_run=True, use_query_cache=False))
    estimate = dry.total_bytes_processed
    if estimate is None or estimate > 100_000_000:
        raise RuntimeError(f'Estimativa inválida: {name}: {estimate}')
    job = client.query(sql, job_config=bigquery.QueryJobConfig(use_query_cache=False, maximum_bytes_billed=100_000_000))
    rows = [dict(row) for row in job.result()]
    evidence[name] = {'sql': sql, 'estimated_bytes': estimate,
        'estimate_sql': estimate_sql or sql,
        'processed_bytes': job.total_bytes_processed, 'billed_bytes': job.total_bytes_billed,
        'cache_hit': job.cache_hit, 'job_id': job.job_id, 'row_count': len(rows)}
    print(name, job.total_bytes_processed, 'bytes')
    return rows

source = 'basedosdados.br_tse_eleicoes.detalhes_votacao_municipio_zona'
filters = "ano IN (2018,2022) AND sigla_uf='DF' AND cargo='presidente' AND tipo_eleicao='eleicao ordinaria' AND turno IN (1,2)"
columns = ['ano','turno','zona','aptos','comparecimento','abstencoes']
all_rows = run('todas_colunas', f'SELECT * FROM `{source}` WHERE {filters} ORDER BY ano,turno,zona')
selected = run('colunas_necessarias', f"SELECT {','.join(columns)} FROM `{source}` WHERE {filters} ORDER BY ano,turno,zona")
assert [{k: r[k] for k in columns} for r in all_rows] == selected

mart = 'eleitorado.eleicoes_em_dados.mart_participacao_zona'
base_select = f'SELECT ano, turno, zona, eleitorado_apto, comparecimento, abstencoes FROM `{mart}`'
variants = {'simples':'', 'particionada':'PARTITION BY RANGE_BUCKET(ano, GENERATE_ARRAY(2018,2024,2))', 'clusterizada':'CLUSTER BY zona'}
outputs = {}
for name, clause in variants.items():
    table = f'eleitorado.eleicoes_em_dados.lab_benchmark_{name}'
    run('criar_' + name, f'CREATE OR REPLACE TABLE `{table}` {clause} OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)) AS {base_select}', base_select)
    outputs[name] = run('consultar_' + name, f"SELECT ano, turno, zona, eleitorado_apto, abstencoes FROM `{table}` WHERE ano=2022 AND zona='1' ORDER BY turno")
assert outputs['simples'] == outputs['particionada'] == outputs['clusterizada']
evidence['validation'] = {'projection_equal':True,'physical_variants_equal':True,
    'source_rows':len(selected),'lab_rows_per_table':76,
    'note':'Projeção compara resultados após selecionar as mesmas colunas. Variantes físicas retornam exatamente o mesmo resultado. Criação das tabelas também está registrada.'}
(root / 'analyses/evidencias/benchmark.json').write_text(json.dumps(evidence,indent=2,default=str),encoding='utf-8')
