# Descrições para currículo

Responsável: Deyvid Prado. Duas versões do mesmo projeto, cada uma com a ênfase da vaga. Todos os números estão nas evidências do repositório. Repositório: https://github.com/Deyv7/eleicoes-em-dados.

---

## Analista de Dados / BI

**Eleições em Dados — participação eleitoral no DF** · Projeto pessoal · [GitHub](https://github.com/Deyv7/eleicoes-em-dados)
BigQuery · dbt · SQL · Power BI · DAX

Dashboard de comparecimento e abstenção por zona eleitoral do Distrito Federal (eleições presidenciais de 2018 e 2022), construído sobre uma tabela validada com dados públicos do TSE.

- Identifiquei na base do TSE duas armadilhas que distorcem o indicador: o eleitorado se repete por cargo, e o mesmo identificador de zona não comprova continuidade territorial entre anos. Defini um recorte e regras de uso que evitam as duas.
- Modelei no Power BI 9 medidas DAX, com taxas ponderadas e comparação 2018 × 2022 em pontos percentuais. Cada valor foi conferido contra totais de referência e consultas SQL independentes.
- Criei o layout no Figma e montei um painel de uma página: KPIs, comparação entre anos, ranking de zonas e participação de cada zona nas abstenções.
- Resultado apresentado: a abstenção no DF caiu 1,16 p.p. no 1º turno e 2,20 p.p. no 2º turno entre 2018 e 2022, sem atribuir causas que os dados não sustentam.

**Versão de uma linha:** Dashboard em Power BI sobre abstenção eleitoral no DF (2018–2022), com medidas DAX conferidas contra SQL e dados validados por 27 testes automatizados.

---

## Engenharia de Dados Jr.

**Eleições em Dados — pipeline analítico com dbt e BigQuery** · Projeto pessoal · [GitHub](https://github.com/Deyv7/eleicoes-em-dados)
BigQuery · dbt Core · SQL · Python · Git

Pipeline que transforma dados públicos do TSE em um mart confiável de participação eleitoral por zona, com testes, documentação e custo zero.

- Pipeline dbt em três camadas (staging → intermediate → mart) sobre o BigQuery sandbox, reconstruível com um único `dbt build`.
- 27 testes de qualidade (18 genéricos e 9 singulares): unicidade da chave, domínios, conciliação `aptos = comparecimento + abstenções` e comparação linha a linha do mart com a fonte. Uma demonstração controlada injeta dados inválidos e comprova que os testes detectam a falha.
- Controle de custo: dry run antes de toda consulta e limite de bytes por job. No benchmark, selecionar só as colunas necessárias reduziu em 62% os bytes lidos, e o filtro de partição reduziu em 50%. Bytes estimados e processados são registrados separadamente.
- Contrato de dados versionado (colunas, tipos, fórmulas e regras de nulos), evidências de execução em JSON e guia de reprodução.

**Versão de uma linha:** Pipeline dbt + BigQuery com 27 testes de qualidade, validação linha a linha contra a fonte e controle de custo por dry run, sobre dados públicos do TSE.

---

## Dicas de uso

- **Escolha 3 bullets por versão.** Em currículo de uma página, o projeto ocupa de 4 a 6 linhas.
- **No LinkedIn**, use a versão de uma linha como título do projeto e cole os bullets na descrição, com o print `dashboard-2022-2turno.png`.
- **Esteja pronto para explicar qualquer número.** As respostas estão em [`roteiro-2min.md`](roteiro-2min.md), na seção "Perguntas prováveis".
- **Transparência:** o projeto foi desenvolvido com apoio de assistentes de IA. Se a vaga ou a entrevista tocar no assunto, vale dizer como você os usou (definição do problema, revisão, decisões de recorte) e demonstrar domínio de cada etapa.
