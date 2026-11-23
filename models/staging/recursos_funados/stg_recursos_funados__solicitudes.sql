-- =============================================================================
-- stg_recursos_funados__solicitudes
-- =============================================================================
-- Capa Staging: relación 1:1 con Bronze. Solo renombrado y casteado.
-- Se castean solo las columnas limpias. Quedan como texto, para Silver:
--   - empleado_id: algunos llevan prefijo (E1234).
--   - tipo_ausencia, estado, dias_laborables: escritos de varias formas.
--   - fecha_inicio, fecha_fin: formato según la sede (dd/mm/aaaa,
--     mm/dd/aaaa o aaaa-mm-dd). Para interpretarlas hay que cruzar con la
--     sede del empleado, y eso no es trabajo de staging.
-- =============================================================================

with source as (
    select * from {{ source('recursos_funados', 'solicitudes') }}
),

renamed as (
    select
          solicitud_id::number          as solicitud_id
        , empleado_id
        , tipo_ausencia
        , creada_en::timestamp_ntz      as creada_en
        , fecha_inicio
        , fecha_fin
        , dias_laborables
        , estado
        , motivo
        , aprobador_id::number          as aprobador_id
        , _fichero_origen               as fichero_origen
        , _cargado_en                   as cargado_en
    from source
)

select * from renamed