-- =============================================================================
-- slv_recursos_funados__departamentos
-- =============================================================================
-- Capa Silver: limpiar, deduplicar y normalizar.
-- Limpieza: 'Mkt' (id 9) es el mismo departamento que 'Marketing' (id 2), dado
-- de alta dos veces en RecursosFunados. Se unifica por id: aquí se elimina el
-- 9, y en empleados y movimientos el 9 se reasigna al 2.
-- =============================================================================

with departamentos as (
    select * from {{ ref('stg_recursos_funados__departamentos') }}
)

select
      departamento_id
    , nombre
from departamentos
where departamento_id != 9     -- 'Mkt': duplicado de Marketing (id 2)