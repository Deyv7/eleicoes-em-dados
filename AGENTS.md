# Instruções para agentes

## Divisão de trabalho (Codex e Claude)

- Codex: `models/`, `analyses/`, configuração dbt e dependências, `.gitignore`, este arquivo, configurações MCP, `docs/contrato-dados.md`, `docs/validacao-fonte.md`, `docs/benchmark.md`, `docs/reproducao.md`.
- Claude: `tests/`, `dashboard/`, `docs/apresentacao/`, `docs/revisao-qualidade.md` e `README.md`.
- Não sobrescrever alterações do outro agente. Solicitar mudanças fora da própria área por documento de passagem.
- `docs/contrato-dados.md` é a referência para modelos, testes e BI; Codex mantém o contrato. Claude registra divergências em `docs/revisao-qualidade.md`.
- Apenas Codex executa construções dbt, experimentos que criam tabelas e operações de Git que alteram o estado compartilhado.
- Claude escreve testes singulares em `tests/`, sem alterar o YAML de `models/`.
- Nunca apresentar arquivos planejados ou um PBIX vazio como dashboard concluído.
- Após a entrega final da Claude comunicada pelo usuário, Codex realiza a revisão editorial de fechamento e publicação, preservando a implementação de testes e BI. A entrega versionada do dashboard é `dashboard/eleicoes-em-dados.pbip`; o PBIX local anterior e caches `.pbi/` não devem ser publicados.

## BigQuery e custo zero

- Manter este projeto no BigQuery sandbox, sem ativar faturamento nem contratar serviços pagos.
- Usar o projeto Google Cloud `eleitorado` e a autenticação Google local existente.
- Conferir a estimativa de processamento por dry run antes de executar consultas analíticas.
- Respeitar as cotas gratuitas. Se estiverem esgotadas, interromper a execução e informar o usuário; não ativar faturamento para contornar a limitação.
- Não versionar tokens, chaves, arquivos de autenticação ou configurações contendo credenciais.
- Distinguir bytes estimados pelo dry run dos bytes efetivamente processados pelo job. Não apresentar estimativas como medições de execução.

## Integração MCP

- O Codex usa `.codex/config.toml`; o Claude Code usa `.mcp.json`.
- Ambos apontam para o Toolbox local em `C:\Users\Deyvid-PC\tools\toolbox.exe`, com `--prebuilt bigquery --stdio`.
- O caminho do executável é específico deste computador; adaptar em outras máquinas sem copiar credenciais.
- Para verificar a conexão, preferir listar ferramentas e consultar metadados da fonte `basedosdados.br_tse_eleicoes.detalhes_votacao_municipio_zona`, sem modificar tabelas.
