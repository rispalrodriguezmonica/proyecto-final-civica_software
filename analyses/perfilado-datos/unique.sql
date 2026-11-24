-- =============================================================================
-- Perfilado · unique · Duplicados
-- =============================================================================
-- Pregunta: ¿hay filas repetidas?
--   - Por clave técnica: el mismo id dos veces.
--   - Por clave de negocio: ids distintos, pero la misma cosa.
-- Resultado: filas que sobran (0 = sin duplicados).
-- =============================================================================

select 'empleados · empleado_id' as comprobacion,
       count(*) - count(distinct empleado_id) as filas_que_sobran
from {{ ref('stg_recursos_funados__empleados') }}

union all
select 'movimientos · movimiento_id',
       count(*) - count(distinct movimiento_id)
from {{ ref('stg_recursos_funados__movimientos') }}

union all
select 'solicitudes · solicitud_id',
       count(*) - count(distinct solicitud_id)
from {{ ref('stg_recursos_funados__solicitudes') }}

union all
select 'festivos · país + fecha',
       count(*) - count(distinct pais_iso, fecha)
from {{ ref('stg_recursos_funados__festivos') }}

union all
select 'empleados · email',
       count(*) - count(distinct lower(trim(email)))
from {{ ref('stg_recursos_funados__empleados') }}

union all
select 'solicitudes · empleado + inicio + fin + tipo',
       count(*) - count(distinct empleado_id, fecha_inicio, fecha_fin, tipo_ausencia)
from {{ ref('stg_recursos_funados__solicitudes') }}