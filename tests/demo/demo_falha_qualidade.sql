{{ config(enabled=var('demo_falha', false)) }}

-- Demonstração controlada — desativada por padrão.
-- Junta às linhas reais do mart três linhas inválidas conhecidas, geradas em CTE
-- (nenhuma tabela é criada ou alterada), e aplica as mesmas regras de T02, T05 e T07.
-- Resultado esperado: o teste FALHA e aponta exatamente as 3 linhas injetadas (zona 'demo-*').
--
-- Executar: dbt test --select demo_falha_qualidade --vars "{demo_falha: true}"

with mart as (
    select ano, turno, zona, eleitorado_apto, comparecimento, abstencoes, taxa_abstencao
    from {{ ref('mart_participacao_zona') }}
),

injetadas as (
    select * from unnest([
        -- 1. conciliação quebrada: 1000 <> 800 + 150
        struct(2022 as ano, 2 as turno, 'demo-conciliacao' as zona,
               1000 as eleitorado_apto, 800 as comparecimento, 150 as abstencoes,
               0.15 as taxa_abstencao),
        -- 2. taxa fora do intervalo [0, 1]
        struct(2022, 2, 'demo-taxa', 1000, 800, 200, 1.2),
        -- 3. chave duplicada (a mesma linha duas vezes)
        struct(2022, 2, 'demo-duplicada', 1000, 800, 200, 0.2),
        struct(2022, 2, 'demo-duplicada', 1000, 800, 200, 0.2)
    ])
),

dados as (
    select * from mart
    union all
    select * from injetadas
),

violacoes as (
    select ano, turno, zona, 'conciliacao' as regra
    from dados
    where eleitorado_apto <> comparecimento + abstencoes

    union all

    select ano, turno, zona, 'taxa fora de [0, 1] ou diferente do recalculo' as regra
    from dados
    where eleitorado_apto > 0
      and (taxa_abstencao not between 0 and 1
           or abs(taxa_abstencao - abstencoes / eleitorado_apto) > 1e-9)

    union all

    select ano, turno, zona, 'chave duplicada' as regra
    from dados
    group by ano, turno, zona
    having count(*) > 1
)

select * from violacoes
