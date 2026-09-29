# Validação da fonte

Verificação executada em 29/09/2026. Evidência integral e IDs dos jobs: `analyses/evidencias/fonte.json`. Script reproduzível: `analyses/validar_fonte.py`.

## Resultados

- Região US, partição por faixa de ano (início 1994, fim 2024, intervalo 2), clustering por sigla_uf.
- 13 grupos ano/turno/cargo/tipo/ID no recorte DF de 2018 e 2022, todos de eleição ordinária.
- Nenhuma contagem nula ou diferença entre aptos e comparecimento + abstenções nesses grupos.
- Presidente: 76 linhas, 19 por ano/turno; nenhuma duplicidade na chave ano/turno/zona.
- As 19 zonas observadas são: 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19, 20, 21. Isso não comprova continuidade territorial entre anos.

## Totais independentes de referência

| Ano | Turno | Zonas/linhas | Eleitorado apto | Comparecimento | Abstenções |
|---|---|---|---|---|---|
| 2018 | 1 | 19 | 2085825 | 1695724 | 390101 |
| 2018 | 2 | 19 | 2086086 | 1691396 | 394690 |
| 2022 | 1 | 19 | 2206996 | 1819900 | 387096 |
| 2022 | 2 | 19 | 2207628 | 1838492 | 369136 |

Os totais acima foram calculados a partir das linhas lidas diretamente da fonte, antes da criação do mart. Não assumir eleitorado idêntico nos dois turnos.

## Processamento das consultas de validação

| Consulta | Estimativa dry run (bytes) | Processados no job (bytes) | Cache |
|---|---|---|---|
| Perfil por cargo/eleição | 7457329 | 7457329 | desativado |
| Linhas presidenciais | 7457329 | 7457329 | desativado |

As consultas adicionam campos de validação às consultas iniciais; os valores não devem ser confundidos com a estimativa anterior de 4,97 MB. Bytes faturados reportados pela API estão na evidência; não representam cobrança monetária no sandbox.

## Observações para o README

Corrigir a descrição física: `ano` é partição e `sigla_uf` é clustering. Cargo presidente e tipo eleicao ordinaria estão confirmados. Fixar um cargo é necessário para evitar contagem múltipla mesmo quando os valores entre cargos coincidem. Não preencher a tabela das consultas antigas com bytes de consultas diferentes.
