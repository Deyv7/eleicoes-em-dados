# Roteiro de apresentação — 2 minutos

Responsável: Deyvid Prado. Roteiro para demonstrar o projeto em entrevista, vídeo ou banca. Todos os números vêm do mart e das evidências do repositório; nenhum foi estimado.

**Arco da história:** um número que parece simples → por que ele engana → como garanti que está certo → o que ele mostra → o que ele **não** mostra.

## Antes de começar (deixar aberto)

1. Dashboard no Power BI (`dashboard/eleicoes-em-dados.pbip`), com **2022 · 2º turno** selecionado.
2. Documentação do dbt com a linhagem (`dbt docs serve --profiles-dir .local`).
3. Terminal com a saída da demonstração de falha (`analyses/evidencias/demo_qualidade.json` ou o comando da demo).
4. README no GitHub, para fechar.

## Roteiro

### 0:00–0:15 · Gancho

> **Tela:** dashboard, cartões do topo.

"No segundo turno de 2022, o Distrito Federal tinha **2,2 milhões** de eleitores aptos, e **369 mil** não foram votar. Parece um número simples de tirar da base do TSE. Não é, e este projeto é sobre garantir que ele esteja certo antes de chegar num gráfico."

### 0:15–0:40 · A armadilha nos dados

> **Tela:** README, seção Recorte, ou a tabela da fonte no BigQuery.

"A base pública repete o eleitorado de cada zona **uma vez por cargo**: presidente, governador, senador. Quem soma sem cuidado multiplica o eleitorado. Além disso, o número de uma zona em 2018 não pode ser comparado com o da 'mesma' zona em 2022, porque nada garante que o território seja o mesmo. Meu estágio em TI no TRE-DF motivou o tema; as regras deste recorte foram verificadas na fonte pública."

### 0:40–1:10 · Como garanti o número

> **Tela:** linhagem do dbt → saída da demonstração com FAIL 3.

"Montei o pipeline no **BigQuery**, sem gastar nada, no sandbox, e transformei com **dbt** em três camadas: staging, intermediate e um mart com uma linha por zona, ano e turno. São **27 testes**: nulos, chave única, as quatro eleições completas, eleitorado igual a comparecimento mais abstenções, e o mart conferido **linha a linha contra a fonte**.

E não basta o teste passar. Criei três casos de erro em dados sintéticos, e o teste **detectou exatamente os três**. É isso que me dá confiança de que ele pega erro de verdade."

### 1:10–1:40 · O que os números mostram

> **Tela:** dashboard; trocar o filtro de turno de 2º para 1º e voltar.

"Com o número confiável, a leitura fica simples. A abstenção do DF **caiu entre 2018 e 2022** nos dois turnos: **1,16 ponto percentual** no primeiro e **2,20** no segundo.

E os anos se comportaram de forma oposta: em 2018 o comparecimento **caiu** do primeiro para o segundo turno; em 2022 ele **subiu**. Dentro da mesma eleição, as zonas vão de **15,0% a 18,6%** de abstenção."

### 1:40–2:00 · Limites e fechamento

> **Tela:** rodapé do dashboard → README.

"Duas coisas que o painel **não** faz, de propósito: não aponta causas, porque são só agregados, e não compara zonas entre anos. Está tudo documentado e reproduzível no repositório: contrato de dados, testes, benchmark de custo e o passo a passo. É um projeto independente, feito com dados públicos do TSE."

## Números usados (conferência)

| Fala | Valor | Fonte |
|---|---|---|
| Eleitorado apto 2022/2 | 2.207.628 | `docs/validacao-fonte.md` |
| Abstenções 2022/2 | 369.136 | `docs/validacao-fonte.md` |
| Testes | 27 aprovados (18 genéricos + 9 singulares) | `analyses/evidencias/build_integrado.json` |
| Demonstração | FAIL com 3 violações | `analyses/evidencias/demo_qualidade.json` |
| Queda da abstenção, 1º turno | −1,16 p.p. (18,70% → 17,54%) | `analyses/evidencias/analises.json` |
| Queda da abstenção, 2º turno | −2,20 p.p. (18,92% → 16,72%) | `analyses/evidencias/analises.json` |
| Comparecimento entre turnos | 2018: −0,22 p.p.; 2022: +0,82 p.p. | `analyses/evidencias/analises.json` |
| Faixa entre zonas, 2022/2 | 14,95% (zona 3) a 18,60% (zona 2) | `analyses/evidencias/analises.json` |

## Perguntas prováveis

**Por que o cargo presidente?**
A fonte repete eleitorado e comparecimento por cargo. Fixar um cargo evita contar o mesmo eleitor várias vezes. Presidente teve segundo turno nos dois anos, então as quatro eleições ficam comparáveis.

**Por que não comparar as zonas entre 2018 e 2022?**
O identificador da zona se repete, mas não verifiquei se os limites territoriais continuaram os mesmos. Comparar seria afirmar algo que os dados não sustentam. Por isso a comparação entre anos é só do DF inteiro.

**Quanto custou?**
Nada. O projeto roda no BigQuery sandbox, sem faturamento. Toda consulta passa por dry run antes, e o profile do dbt limita cada job a 100 MB.

**O benchmark provou economia?**
Provou redução de **bytes lidos**: 62% selecionando só as colunas necessárias e 50% com filtro de partição. Não provou economia em dinheiro: nas cópias de laboratório, os jobs reportaram os mesmos 10 MiB faturados; os jobs de leitura da fonte tiveram volumes diferentes. Está documentado assim em `docs/benchmark.md`.

**Por que testes genéricos e singulares?**
Os genéricos checam propriedades de coluna. Os singulares foram escritos de forma independente dos modelos intermediários: refazem o recorte direto da fonte e comparam. Se houver erro na transformação, eles não herdam o erro.

**A queda da abstenção tem a ver com quê?**
Os dados deste recorte não permitem dizer. Para atribuir causa, eu precisaria de outras variáveis e de outro desenho de análise.

## Versões curtas

- **30 segundos (elevador):** gancho + "garanti o número com dbt e 27 testes, inclusive um que prova que o teste pega erro" + o achado de −2,20 p.p. no 2º turno.
- **Foco em BI:** alongar 1:10–1:40 e mostrar a interação dos filtros; resumir a parte de testes numa frase.
- **Foco em engenharia de dados:** alongar 0:40–1:10, mostrar a linhagem, o contrato de dados e o preflight de custo; resumir os achados numa frase.
