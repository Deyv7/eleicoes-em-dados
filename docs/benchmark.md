# Benchmark de processamento — 29/09/2026

Executado por `analyses/benchmark.py`. SQL exato, IDs de jobs, bytes e cache em `analyses/evidencias/benchmark.json`.

## Método

- Mesmo recorte presidencial DF/2018/2022 e eleição ordinária.
- Dry run antes de cada execução; limite de 100.000.000 bytes por job.
- Cache de resultados desativado e confirmado como `false` nas respostas.
- Projeção: SELECT * comparado a seis colunas, com igualdade verificada depois de projetar as mesmas colunas no resultado amplo.
- Organização física: três cópias idênticas do mart, cada uma com 76 linhas e seis colunas. Uma simples, uma particionada por ano e uma clusterizada por zona, isolando as duas técnicas.
- Consulta das cópias: ano 2022 e zona '1', ordenada por turno. Resultados idênticos nas três variantes, verificados por comparação dos registros.
- Experimento de uma execução por variante; não é benchmark de latência nem avaliação de grande escala.

## Projeção de colunas na fonte

| Consulta | Bytes estimados | Bytes processados | Bytes faturados reportados |
|---|---|---|---|
| Todas as colunas | 17180996 | 17180996 | 17825792 |
| Somente ano, turno, zona, aptos, comparecimento, abstencoes | 6500065 | 6500065 | 10485760 |

Selecionar as colunas necessárias reduziu o volume processado em aproximadamente 62,2%. Os resultados completos das duas consultas são diferentes em largura; a igualdade foi conferida somente sobre as seis colunas comuns. Não confundir esse experimento com uma otimização que preserva todas as colunas de SELECT *.

## Particionamento e clustering nas cópias pequenas

| Organização | Bytes estimados | Bytes processados | Bytes faturados reportados |
|---|---|---|---|
| Sem particionamento/clustering | 2704 | 2704 | 10485760 |
| Particionada por ano | 1352 | 1352 | 10485760 |
| Clusterizada por zona | 2704 | 2704 | 10485760 |

O filtro de ano eliminou metade dos bytes na tabela particionada. O clustering não reduziu a leitura neste conjunto minúsculo. Todas as variantes tiveram o mesmo mínimo de bytes faturados reportado pela API; portanto, a redução de bytes processados da partição não se converteu em redução de bytes faturados nesse teste.

Cada criação de cópia processou 3312 bytes e reportou 10485760 bytes faturados; esse trabalho adicional também faz parte do custo operacional do experimento. As tabelas `lab_benchmark_*` expiram automaticamente em 24 horas. O mart final permanece sem particionamento/clustering artificial.

## Conclusão e limites

O resultado demonstra seleção de colunas e eliminação de partições, não economia financeira comprovada. Bytes faturados são uma métrica técnica do job; o projeto opera no sandbox sem faturamento ativado. Não houve medição de redução em reais nem de velocidade. Um dataset de 76 linhas não permite extrapolar ganhos para produção.
