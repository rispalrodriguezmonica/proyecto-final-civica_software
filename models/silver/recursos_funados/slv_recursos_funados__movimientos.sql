-- =============================================================================
-- slv_recursos_funados__movimientos
-- =============================================================================
-- Capa Silver: limpiar, deduplicar y normalizar.
-- Historial de cambios de departamento: base de la SCD tipo 2 de dim_empleado.
-- Limpieza: el departamento 9 ('Mkt') se reasigna al 2 (Marketing), igual que
-- en empleados, para que el historial y el estado actual coincidan.
-- =============================================================================

with movimientos as (
    select * from {{ ref('stg_recursos_funados__movimientos') }}
)

select
      movimiento_id
    , empleado_id
    , fecha_efectiva
    , case when departamento_anterior_id = 9 then 2 else departamento_anterior_id end
                                                    as departamento_anterior_id
    , case when departamento_nuevo_id = 9 then 2 else departamento_nuevo_id end
                                                    as departamento_nuevo_id
    , motivo
from movimientos