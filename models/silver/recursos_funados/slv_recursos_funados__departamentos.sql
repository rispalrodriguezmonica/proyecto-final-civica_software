-- =============================================================================
-- slv_recursos_funados__departamentos
-- =============================================================================
-- Capa Silver: limpiar, deduplicar y normalizar.
-- Normalización: el departamento llega repetido en cada empleado. Aquí se
-- extrae una fila por departamento.
-- Limpieza: 'Mkt' (id 9) es el mismo departamento que 'Marketing' (id 2). Se
-- unifica por id: aquí se elimina el 9, y en empleados y movimientos se
-- reasigna al 2.
-- =============================================================================

with empleados as (
    select * from {{ ref('stg_recursos_funados__empleados') }}
)

select distinct
      departamento_id
    , nombre_departamento       as nombre
from empleados
where departamento_id is not null
  and departamento_id != 9      -- 'Mkt': duplicado de Marketing (id 2)