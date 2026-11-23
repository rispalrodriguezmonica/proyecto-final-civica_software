-- =============================================================================
-- stg_recursos_funados__movimientos
-- =============================================================================
-- Capa Staging: relación 1:1 con Bronze. Solo renombrado y casteado.
-- Historial de cambios de departamento: base de la SCD tipo 2 de dim_empleado.
-- =============================================================================

with source as (
    select * from {{ source('recursos_funados', 'movimientos') }}
),

renamed as (
    select
          movimiento_id::number             as movimiento_id
        , empleado_id::number               as empleado_id
        , fecha_efectiva::date              as fecha_efectiva
        , departamento_anterior_id::number  as departamento_anterior_id
        , departamento_nuevo_id::number     as departamento_nuevo_id
        , motivo
        , _fichero_origen                   as fichero_origen
        , _cargado_en                       as cargado_en
    from source
)

select * from renamed