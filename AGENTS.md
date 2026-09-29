# Orientações do projeto

## Manutenção

- Responsável pelo projeto: Deyvid Prado.
- Preservar alterações em andamento e manter modelos, testes, documentação e dashboard consistentes.
- O contrato em docs/contrato-dados.md é a referência para modelos, testes e BI. Registrar divergências em docs/revisao-qualidade.md.
- Nunca apresentar arquivos planejados ou um PBIX vazio como dashboard concluído.
- A entrega versionada do dashboard é dashboard/eleicoes-em-dados.pbip; o PBIX inicial e caches .pbi/ não devem ser publicados.

## BigQuery e custo zero

- Manter o projeto no BigQuery sandbox, sem ativar faturamento nem contratar serviços pagos.
- Usar o projeto Google Cloud eleitorado e a autenticação local existente.
- Conferir a estimativa de processamento por dry run antes de executar consultas analíticas.
- Respeitar as cotas gratuitas. Se estiverem esgotadas, interromper a execução e informar o responsável; não ativar faturamento.
- Não versionar tokens, chaves, arquivos de autenticação ou configurações contendo credenciais.
- Distinguir bytes estimados dos bytes efetivamente processados. Não apresentar estimativas como medições de execução.
