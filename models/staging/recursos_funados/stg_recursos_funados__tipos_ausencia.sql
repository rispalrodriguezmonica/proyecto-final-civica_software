-- =============================================================================
-- stg_recursos_funados__tipos_ausencia
-- =============================================================================
-- Capa Staging: relación 1:1 con Bronze. Solo renombrado y casteado.
-- requiere_aprobacion y retribuida llegan como 'S'/'N': se pasan a boolean.
-- =============================================================================

with source as (
    select * from {{ source('recursos_funados', 'tipos_ausencia') }}
),

renamed as (
    select
          codigo                        as tipo_ausencia_codigo
        , nombre
        , requiere_aprobacion = 'S'     as requiere_aprobacion
        , retribuida = 'S'              as retribuida
        , _fichero_origen               as fichero_origen
        , _cargado_en                   as cargado_en
    from source
)

select * from renamed