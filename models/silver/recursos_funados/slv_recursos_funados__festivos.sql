-- =============================================================================
-- slv_recursos_funados__festivos
-- =============================================================================
-- Capa Silver: limpiar, deduplicar y normalizar.
-- Limpieza: 12 festivos llegan repetidos (mismo país y fecha). Se deduplica por
-- la clave de negocio (pais_iso, fecha). Si no, al cruzar festivos con
-- solicitudes se duplicarían filas y los recuentos saldrían inflados.
-- =============================================================================

with festivos as (
    select * from {{ ref('stg_recursos_funados__festivos') }}
)

select
      pais_iso
    , fecha
    , nombre_festivo
from festivos
qualify row_number() over (
    partition by pais_iso, fecha
    order by nombre_festivo
) = 1